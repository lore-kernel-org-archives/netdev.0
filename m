From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 11/15]bnx2x: Add TPA, Broadcoms HW LRO
Date: Thu, 19 Jun 2008 19:20:11 +0100
Message-ID: <20080619182010.GW5350@solarflare.com>
References: <1213714166.5817.181.camel@lb-tlvb-eliezer> <20080617150539.GJ5350@solarflare.com> <20080617151704.GK5350@solarflare.com> <20080617.161640.256235010.davem@davemloft.net> <1213897363.19376.1.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mchan@broadcom.com, vladz@broadcom.com
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.mbr-roch.zen.net.uk ([212.23.3.141]:51601 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753886AbYFSSUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 14:20:18 -0400
Content-Disposition: inline
In-Reply-To: <1213897363.19376.1.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eilon Greenstein wrote:
> 
> On Tue, 2008-06-17 at 16:16 -0700, David Miller wrote:
> > From: Ben Hutchings <bhutchings@solarflare.com>
> > Date: Tue, 17 Jun 2008 16:17:06 +0100
> > 
> > > Ben Hutchings wrote:
> > > > Eilon Greenstein wrote:
> > > > > The TPA stands for Transparent Packet Aggregation. When enabled, the FW
> > > > > aggregate in-order TCP packets according to the 4-tuple match and sends
> > > > > 1 big packet to the driver. This packet is stored on an SGL in which
> > > > > each SGE is 1 page. The FW also implements a timeout algorithm and it
> > > > > honors all TCP flag, including the push flag as a trigger to halt
> > > > > aggregation.
> > > > [...]
> > > > 
> > > > LRO is not compatible with forwarding and will currently trigger a BUG() or
> > > > WARN() if used on packets that are then forwarded.
> > > 
> > > Actually, since this implementation doesn't set gso_size in LRO'd skbs, it
> > > will confuse TCP in interesting ways instead.  You need to set gso_size to
> > > the largest segment size seen in the packets that were aggregated.
> > 
> > Eilon, please sort this out, thanks.
> Just to make sure that we are working in the right direction: we will
> add the ethtool support and the gso_size, but until Ben's patch will be
> in place, we will still fail in the same way any other LRO driver will
> fail in forwarding.
> If this is the case, I will send another patch with the ethtool and
> gso_size soon.

I just posted a new version of the no-LRO-with-forwarding patches.  It
might be worth testing your ethtool flags code against them, though it
should just work if you clear and set NETIF_F_LRO appropriately.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
