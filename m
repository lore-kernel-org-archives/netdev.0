From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC] gre: transparent ethernet bridging
Date: Fri, 4 Aug 2006 10:02:36 +0200
Message-ID: <20060804080236.GA4106@xi.wantstofly.org>
References: <44CDD631.5030008@snapgear.com> <20060731091423.3327f85e@dxpl.pdx.osdl.net> <44CEAB31.5090501@snapgear.com> <20060731220822.444f04e4@localhost.localdomain> <20060802074223.GA23715@xi.wantstofly.org> <44D15265.4090905@snapgear.com> <20060803073307.GA29775@xi.wantstofly.org> <44D1BE93.1080308@snapgear.com> <20060803194016.GC527@xi.wantstofly.org> <44D29C47.6080407@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:29657 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1161098AbWHDICl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 04:02:41 -0400
To: Philip Craig <philipc@snapgear.com>
Content-Disposition: inline
In-Reply-To: <44D29C47.6080407@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 04, 2006 at 11:00:55AM +1000, Philip Craig wrote:

> >>> So now you _need_ bridging in the middle to send ethernet traffic over
> >>> a GRE tunnel?  Ugh.
> >> Agreed that would not be nice.  What is the usage scenario for this?
> >> At least one end of the tunnel will be bridged?
> > 
> > For example for VPN purposes, I could imagine that you wouldn't want
> > to use bridging.
> 
> What is the purpose of including the ethernet header if it only
> exists on the tunnel?

I have one machine at home that appears to be on my employer's network
via such a tunnel.  I don't use bridging, because I don't need any other
machine at home to access this tunnel.  I do want bridging, and not proxy
ARP, because it allows me to run arpwatch, and doesn't require me to
reconfigure something at the remote end if I, for example, want to add
another IP address to my home box.


> >>> If you really want to send ethernet and non-ethernet traffic over the
> >>> same tunnel, can't you make multiple devices?
> >> Do you mean make multiple GRE devices, where one has an ethernet mode set?
> > 
> > For example.  If you want to send ethernet-encapsulated and other-protocol-
> > encapsulated traffic over the same GRE tunnel, that would seem like the
> > cleanest solution to me.
> 
> It is fine for sending, but when receiving, which packets go to which
> device?  Does a packet appear on only one device when sending, but both
> devices when receiving?

No, just send it to the device that matches the lower-level protocol.
So if you receive an ethernet packet, make it be received on the ethernet
sub-device, if it's IP, make it be received on the IP sub-device, etc.

Note that I'm not saying that this is necessarily a good idea, it's just
what I would suggest if you want to run both 'bare IP' and ethernet
encapsulated traffic over the same GRE tunnel at the same time.  (Not sure
why you'd want that.)


> This seems cleaner to me:
> The GRE tunnel receives a packet of any protocol (ethernet included),
> and adds the IP/GRE header.  Anything else is done above GRE.
> Whatever needs the ethernet header should add it.
> 
> And then the decision is, how do we add the ethernet header?
> - an option to GRE to always add the ethernet header

I think I lost you here.  You surely can't just 'make up' any ethernet
header?


cheers,
Lennert
