From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v4 1/1] net: fec: Enable imx6 enet checksum
 acceleration.
Date: Fri, 19 Apr 2013 16:56:46 +0100
Message-ID: <1366387006.2716.3.camel@bwh-desktop.uk.solarflarecom.com>
References: <Jim Baxter <jim_baxter@mentor.com>
	  <1366384215-21441-1-git-send-email-jim_baxter@mentor.com>
	 <1366385398.16391.19.camel@edumazet-glaptop> <517168DB.4050705@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, <netdev@vger.kernel.org>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:54560 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754400Ab3DSP4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 11:56:51 -0400
In-Reply-To: <517168DB.4050705@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 16:55 +0100, Jim Baxter wrote:
> On 19/04/13 16:29, Eric Dumazet wrote:
> > On Fri, 2013-04-19 at 16:10 +0100, Jim Baxter wrote:
> >>  
> >> +static int
> >> +fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
> >> +{
> >> +	/* Only run for packets requiring a checksum. */
> >> +	if (skb->ip_summed != CHECKSUM_PARTIAL)
> >> +		return 0;
> >> +
> >> +	if (unlikely(skb_cow_head(skb, 0)))
> >> +		return -1;
> >> +
> >> +	*(__sum16 *)(skb->head + skb->csum_start + skb->csum_offset) = 0;
> >> +
> >> +	return 0;
> >> +}
> > 
> > 
> >  
> >> +	/* HW acceleration for ICMP TCP UDP checksum */
> >> +	if (fec_enet_clear_csum(skb, ndev))
> >> +		return NETDEV_TX_BUSY;
> > 
> > No : You must drop the packet and return NETDEV_TX_OK
> > 
> > 
> > 
> 
> I have no issue with changing it, but I am curious, by returning OK will
> the kernel not regard it a sent packet and it will be lost?

Correct.  This is normal behaviour when short of memory; look at any
other driver that allocates memory on the TX path.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
