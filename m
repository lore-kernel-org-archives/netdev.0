From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC] gre: transparent ethernet bridging
Date: Thu, 3 Aug 2006 09:33:07 +0200
Message-ID: <20060803073307.GA29775@xi.wantstofly.org>
References: <44CDD631.5030008@snapgear.com> <20060731091423.3327f85e@dxpl.pdx.osdl.net> <44CEAB31.5090501@snapgear.com> <20060731220822.444f04e4@localhost.localdomain> <20060802074223.GA23715@xi.wantstofly.org> <44D15265.4090905@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:47058 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S932362AbWHCHdK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 03:33:10 -0400
To: Philip Craig <philipc@snapgear.com>
Content-Disposition: inline
In-Reply-To: <44D15265.4090905@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 11:33:25AM +1000, Philip Craig wrote:

> >>> All it does is encapsulate the full ethernet header in a gre packet,
> >>> rather than only layer 3.  That is, currently gre uses ARPHRD_IPGRE,
> >>> but bridging requires ARPHRD_ETHER.
> >>
> >> I am not against making the bridge code smarter to handle other
> >> encapsulation.
> > 
> > What if you want to run ethernet directly over a GRE tunnel, without
> > using bridging?
> 
> But on the other hand, this method allows you to send both ethernet
> and non-ethernet traffic over the same GRE tunnel.  Is that useful?
> Actually, this feature is what makes the handling of the LLC_SAP_BSPAN
> packets simple.
> 
> The patch to bridging is a lot cleaner than the patch to GRE, and it
> also sidesteps the userspace configuration issues, so I don't want to
> go back to modifying the GRE device.

So now you _need_ bridging in the middle to send ethernet traffic over
a GRE tunnel?  Ugh.

If you really want to send ethernet and non-ethernet traffic over the
same tunnel, can't you make multiple devices?

If GRE generally transmits BPDUs without ethernet header, the handling
for that ought to be in GRE, IMHO.


cheers,
Lennert
