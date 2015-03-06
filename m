From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v4 0/3] Linn Ethernet Packet Sniffer driver
Date: Fri, 6 Mar 2015 16:22:40 +0100
Message-ID: <20150306152239.GC26349@localhost.localdomain>
References: <cover.1424796018.git.stathis.voukelatos@linn.co.uk>
 <20150225151945.GB7703@localhost.localdomain>
 <20150225170127.GD7703@localhost.localdomain>
 <54EE0268.2040201@linn.co.uk>
 <20150225173053.GE7703@localhost.localdomain>
 <54F0A4C4.3020407@linn.co.uk>
 <20150227181447.GA11594@localhost.localdomain>
 <54F98660.5070805@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54F98660.5070805@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 06, 2015 at 10:50:08AM +0000, Stathis Voukelatos wrote:
> Although the PTP way appears to be the best from an architectural point
> of view, we have some questions as whether it is suitable for the audio
> use cases that this module is mainly intended for.
> To use the PTP terminology in a large installation we would have a
> potentially large number of clock domains.
> It is not clear how to easily manage the creation and allocation of
> domains. In addition the clock will be pulled according to the audio
> stream and it would be undesirable for other unrelated PTPv2 devices
> on the network to join the clock domain and have their clocks
> synchronized to it.

I don't really know what the problem here is.  Yes, there is some
networking configuration that you need to do when administering a
network using PTP protocols.  But these protocols (1588 aka PTP, and
802.1AS aka gPTP) do offer means for dealing with this.  In
particular, there is no danger mixing 1588 devices with audio devices,
because the gPTP protocol uses a different transport flag.

In any case, this has nothing at all to do with the kernel interface.
 
> The patch in its current form would allow a move to Linux using our
> existing synchronization protocols (which are open-source). A move
> to PTP is something to consider but will involve a fair amount of
> redesign including upgrade of legacy products.

If you want to try and integrate your custom protocols into the
networking stack, by all means please post them.  I would certainly
support expanding the time stamping interface to include your
protocol's packet types (like adding them to hwtstamp_rx_filters).
Maybe that would be enough for you?

Thanks,
Richard
