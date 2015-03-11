From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v4 0/3] Linn Ethernet Packet Sniffer driver
Date: Wed, 11 Mar 2015 16:03:48 +0100
Message-ID: <20150311150348.GA11272@localhost.localdomain>
References: <cover.1424796018.git.stathis.voukelatos@linn.co.uk>
 <20150225151945.GB7703@localhost.localdomain>
 <20150225170127.GD7703@localhost.localdomain>
 <54EE0268.2040201@linn.co.uk>
 <20150225173053.GE7703@localhost.localdomain>
 <54F0A4C4.3020407@linn.co.uk>
 <20150227181447.GA11594@localhost.localdomain>
 <54F98660.5070805@linn.co.uk>
 <20150306152239.GC26349@localhost.localdomain>
 <5500251B.8010900@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5500251B.8010900@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 11, 2015 at 11:20:59AM +0000, Stathis Voukelatos wrote:
> Our feeling is that we will have to test and verify that a move to gPTP
> will fit with the use cases that we have to support and that will
> require a fair amount of effort and rewrite of application software.
> If the driver is not acceptable with the current interface we may need
> to maintain it as a private patch until we are ready to move to gPTP
> as you recommend.

Sure, there is nothing wrong with that.  For the kernel, we want to
build good interfaces for future applications.  Sometimes reworking
the applications that use the old, private interfaces is just too much
work, so you have to maintain those interfaces in your products.

> I was referring to the Songcast protocol we are using which is part
> of the OpenHome suite (www.openhome.org) and runs on top of UDP.
> It could be filtered by testing the first 5 bytes of the payload.

Sounds promising.

> In our implementation we also add the destination IP and port to
> the filter to make it more reliable, but hwtstamp_rx_filters cannot
> accept parameters.

If the IP is a defined multicast group address, and if the port is
well a known port, then you should of course include them in the
driver level filter.

Adding a unicast destination IP doesn't make it more reliable, because
frames addressed to other hosts are switched away from the host (or
dropped by the MAC).

> However, I will test that and maybe come back with
> a patch to expand the hwtstamp_rx_filter enum initially?

It probably makes more sense to present the expanded filter list in
the same patch series with the new driver that uses it, in order to
see the context.  So I would hold off posting until both are ready.

Thanks,
Richard
