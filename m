From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next 11/15]bnx2x: Add TPA, Broadcoms HW LRO
Date: Thu, 19 Jun 2008 20:42:43 +0300
Message-ID: <1213897363.19376.1.camel@lb-tlvb-eliezer>
References: <1213714166.5817.181.camel@lb-tlvb-eliezer>
 <20080617150539.GJ5350@solarflare.com>
 <20080617151704.GK5350@solarflare.com>
 <20080617.161640.256235010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	mchan@broadcom.com, vladz@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4395 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171AbYFSRmx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 13:42:53 -0400
In-Reply-To: <20080617.161640.256235010.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-06-17 at 16:16 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Tue, 17 Jun 2008 16:17:06 +0100
> 
> > Ben Hutchings wrote:
> > > Eilon Greenstein wrote:
> > > > The TPA stands for Transparent Packet Aggregation. When enabled, the FW
> > > > aggregate in-order TCP packets according to the 4-tuple match and sends
> > > > 1 big packet to the driver. This packet is stored on an SGL in which
> > > > each SGE is 1 page. The FW also implements a timeout algorithm and it
> > > > honors all TCP flag, including the push flag as a trigger to halt
> > > > aggregation.
> > > [...]
> > > 
> > > LRO is not compatible with forwarding and will currently trigger a BUG() or
> > > WARN() if used on packets that are then forwarded.
> > 
> > Actually, since this implementation doesn't set gso_size in LRO'd skbs, it
> > will confuse TCP in interesting ways instead.  You need to set gso_size to
> > the largest segment size seen in the packets that were aggregated.
> 
> Eilon, please sort this out, thanks.
Just to make sure that we are working in the right direction: we will
add the ethtool support and the gso_size, but until Ben's patch will be
in place, we will still fail in the same way any other LRO driver will
fail in forwarding.
If this is the case, I will send another patch with the ethtool and
gso_size soon.

Please confirm,
Eilon




