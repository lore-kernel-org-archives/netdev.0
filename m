From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v2 1/1] net: fec: Enable imx6 enet checksum
 acceleration.
Date: Tue, 16 Apr 2013 23:41:37 +0100
Message-ID: <1366152097.2645.63.camel@bwh-desktop.uk.solarflarecom.com>
References: <y> <1366108587-3866-1-git-send-email-jim_baxter@mentor.com>
	 <1366126763.2645.18.camel@bwh-desktop.uk.solarflarecom.com>
	 <516DCD7B.1030609@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, <netdev@vger.kernel.org>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:19575 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965426Ab3DPWll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 18:41:41 -0400
In-Reply-To: <516DCD7B.1030609@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-16 at 23:15 +0100, Jim Baxter wrote:
> On 16/04/13 16:39, Ben Hutchings wrote:
[...]
> >> @@ -818,6 +890,19 @@ fec_enet_rx(struct net_device *ndev, int budget)
> >>  				spin_unlock_irqrestore(&fep->tmreg_lock, flags);
> >>  			}
> >>  
> >> +			if (fep->bufdesc_ex &&
> >> +				(fep->csum_flags & FLAG_RX_CSUM_ENABLED)) {
> >> +				struct bufdesc_ex *ebdp =
> >> +					(struct bufdesc_ex *)bdp;
> >> +				if (!(ebdp->cbd_esc & FLAG_RX_CSUM_ENABLED)) {
> >> +					/* don't check it */
> >> +					skb->ip_summed = CHECKSUM_UNNECESSARY;
> > 
> > This looks very strange.  Presumably the RX_ICE and RX_PCR flags
> > indicate checksum errors, and therefore !(ebdp->cbd_esc &
> > FLAG_RX_CSUM_ENABLED) means the checksum(s) are good?  This would be
> > clearer if you defined FLAG_RX_CSUM_ERROR as well (with the same numeric
> > value).
> >
> Agreed, that would be clearer.
> >> +				} else {
> >> +					ndev->stats.rx_errors++;
> > 
> > Layer 3 and 4 errors should not be counted in the net device stats.
> > 
> Ok, are they just for Levls 1 and  2?
[...]

Right, that's my understanding.  Our job as driver writers is to
validate at layer 1 and 2 (FCS error, length error, MAC filtering).
Checksum validation at layers 3 and 4 is an optimisation and the kernel
stack takes care of counting checksum errors.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
