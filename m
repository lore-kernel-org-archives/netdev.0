From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] MPLS: Add limited GSO support
Date: Thu, 4 Apr 2013 09:17:23 +0900
Message-ID: <20130404001722.GC29678@verge.net.au>
References: <1364966697-20131-1-git-send-email-horms@verge.net.au>
 <1365004780.2897.3.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:54245 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759285Ab3DDAR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 20:17:27 -0400
Content-Disposition: inline
In-Reply-To: <1365004780.2897.3.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 03, 2013 at 04:59:40PM +0100, Ben Hutchings wrote:
> I don't know anything about MPLS so this is a pretty superficial review.
> 
> On Wed, 2013-04-03 at 14:24 +0900, Simon Horman wrote:
> [...]
> > --- a/include/linux/netdev_features.h
> > +++ b/include/linux/netdev_features.h
> > @@ -43,6 +43,7 @@ enum {
> >  	NETIF_F_FSO_BIT,		/* ... FCoE segmentation */
> >  	NETIF_F_GSO_GRE_BIT,		/* ... GRE with TSO */
> >  	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
> > +	NETIF_F_GSO_MPLS_BIT,		/* ... MPLS segmentation */
> >  	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
> >  		NETIF_F_GSO_UDP_TUNNEL_BIT,
> 
> You need to change NETIF_F_GSO_LAST as well.

Thanks, I have fixed that in v2.

> 
> [...]
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> [...]
> > @@ -2789,12 +2791,17 @@ static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
> >  }
> >  #endif
> >  
> > -/* Keeps track of mac header offset relative to skb->head.
> > - * It is useful for TSO of Tunneling protocol. e.g. GRE.
> > - * For non-tunnel skb it points to skb_mac_header() and for
> > - * tunnel skb it points to outer mac header. */
> >  struct skb_gso_cb {
> > +	/* Keeps track of mac header offset relative to skb->head.
> > +	 * It is useful for TSO of Tunneling protocol. e.g. GRE.
> > +	 * For non-tunnel skb it points to skb_mac_header() and for
> > +	 * tunnel skb it points to outer mac header. */
> >  	int mac_offset;
> > +
> > +	/* Keeps track of the ethernet type of an encapsualted
> [...]
> 
> Typo: 'encapsualted' should be 'encapsulated'.

Thanks, I will fix that in v3.
