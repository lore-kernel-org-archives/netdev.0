From: Bill Fink <billfink@mindspring.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Wed, 14 Jul 2010 22:52:40 -0400
Message-ID: <20100714225240.e1bf8679.billfink@mindspring.com>
References: <4C3D94E3.9080103@wildgooses.com>
	<4C3DD5EB.9070908@tmr.com>
	<20100714.111553.104052157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davidsen@tmr.com, lists@wildgooses.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100714.111553.104052157.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Jul 2010, David Miller wrote:

> From: Bill Davidsen <davidsen@tmr.com>
> Date: Wed, 14 Jul 2010 11:21:15 -0400
> 
> > You may have to go into /proc/sys/net/core and crank up the
> > rmem_* settings, depending on your distribution.
> 
> You should never, ever, have to touch the various networking sysctl
> values to get good performance in any normal setup.  If you do, it's a
> bug, report it so we can fix it.
> 
> I cringe every time someone says to do this, so please do me a favor
> and don't spread this further. :-)
> 
> For one thing, TCP dynamically adjusts the socket buffer sizes based
> upon the behavior of traffic on the connection.
> 
> And the TCP memory limit sysctls (not the core socket ones) are sized
> based upon available memory.  They are there to protect you from
> situations such as having so much memory dedicated to socket buffers
> that there is none left to do other things effectively.  It's a
> protective limit, rather than a setting meant to increase or improve
> performance.  So like the others, leave these alone too.

What's normal?  :-)

netem1% cat /proc/version 
Linux version 2.6.30.10-105.2.23.fc11.x86_64 (mockbuild@x86-01.phx2.fedoraproject.org) (gcc version 4.4.1 20090725 (Red Hat 4.4.1-2) (GCC) ) #1 SMP Thu Feb 11 07:06:34 UTC 2010

Linux TCP autotuning across an 80 ms RTT cross country network path:

netem1% nuttcp -T10 -i1 192.168.1.18
   14.1875 MB /   1.00 sec =  119.0115 Mbps     0 retrans
  558.0000 MB /   1.00 sec = 4680.7169 Mbps     0 retrans
  872.8750 MB /   1.00 sec = 7322.3527 Mbps     0 retrans
  869.6875 MB /   1.00 sec = 7295.5478 Mbps     0 retrans
  858.4375 MB /   1.00 sec = 7201.0165 Mbps     0 retrans
  857.3750 MB /   1.00 sec = 7192.2116 Mbps     0 retrans
  865.5625 MB /   1.00 sec = 7260.7193 Mbps     0 retrans
  872.3750 MB /   1.00 sec = 7318.2095 Mbps     0 retrans
  862.7500 MB /   1.00 sec = 7237.2571 Mbps     0 retrans
  857.6250 MB /   1.00 sec = 7194.1864 Mbps     0 retrans

 7504.2771 MB /  10.09 sec = 6236.5068 Mbps 11 %TX 25 %RX 0 retrans 80.59 msRTT

Manually specified 100 MB TCP socket buffer on the same path:

netem1% nuttcp -T10 -i1 -w100m 192.168.1.18
  106.8125 MB /   1.00 sec =  895.9598 Mbps     0 retrans
 1092.0625 MB /   1.00 sec = 9160.3254 Mbps     0 retrans
 1111.2500 MB /   1.00 sec = 9322.6424 Mbps     0 retrans
 1115.4375 MB /   1.00 sec = 9356.2569 Mbps     0 retrans
 1116.4375 MB /   1.00 sec = 9365.6937 Mbps     0 retrans
 1115.3125 MB /   1.00 sec = 9356.2749 Mbps     0 retrans
 1121.2500 MB /   1.00 sec = 9405.6233 Mbps     0 retrans
 1125.5625 MB /   1.00 sec = 9441.6949 Mbps     0 retrans
 1130.0000 MB /   1.00 sec = 9478.7479 Mbps     0 retrans
 1139.0625 MB /   1.00 sec = 9555.8559 Mbps     0 retrans

10258.5120 MB /  10.20 sec = 8440.3558 Mbps 15 %TX 40 %RX 0 retrans 80.59 msRTT

The manually selected TCP socket buffer size both ramps up
quicker and achieves a much higher steady state rate.

					-Bill
