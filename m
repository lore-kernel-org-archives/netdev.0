From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Thu, 06 Oct 2011 23:27:35 -0400
Message-ID: <6.2.5.6.2.20111006231958.039bb570@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Christoph Lameter <cl@gentwo.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Will
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After writing the last post, the large
difference in IRQ rate between the older
and newer kernels caught my eye.

I wonder if the hugely lower rate in the older
kernels reflects a more agile shifting
into and out of NAPI mode by the network
bottom-half.

In this test the sending system
pulses data out on millisecond boundaries
due to the behavior of nsleep(), which
is used to establish the playback pace.

If the older kernels are switching to NAPI
for much of surge and the switching out
once the pulse falls off, it might
conceivably result in much better latency
and overall performance.

All tests were run with Intel 82571 
network interfaces and the 'e1000e'
device driver.  Some used the driver
packaged with the kernel, some used
Intel driver compiled from the source
found on sourceforge.net.  Never could
detected any difference between the two.

Since data in the production environment
also tends to arrive in bursts, I don't find
the pulsing playback behavior a detriment.
