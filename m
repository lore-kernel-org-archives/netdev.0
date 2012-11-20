From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen/netfront: handle compound page fragments on transmit
Date: Tue, 20 Nov 2012 15:05:41 +0000
Message-ID: <1353423941.13542.47.camel@zakaz.uk.xensource.com>
References: <1353403286.18229.159.camel@zakaz.uk.xensource.com>
	 <1353411606-15940-1-git-send-email-ian.campbell@citrix.com>
	 <1353422735.2590.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Eric Dumazet <edumazet@google.com>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	ANNIE LI <annie.li@oracle.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	"Stefan Bader" <stefan.bader@canonical.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:20382 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230Ab2KTPFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 10:05:45 -0500
In-Reply-To: <1353422735.2590.6.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-20 at 14:45 +0000, Eric Dumazet wrote:
> > +		/* Skip unused frames from start of page */
> 
> 'frame' in the comment means an order-0 page ?

Yes. Confusing in the context of a network driver I know! I couldn't
think of a better term.

> > +			id = get_id_from_freelist(&np->tx_skb_freelist, np->tx_skbs);
> > +			np->tx_skbs[id].skb = skb_get(skb);
> 
> BTW this skb_get() means extra atomic operations for every 4096 bytes
> unit, and an extra atomic op (and test for final 0) at TX completion.
> This could be avoided, by setting np->tx_skbs[id].skb = skb only for the
> very last unit.

Thanks. Might be tricky because guests can ack the individual requests
in any order but it's something worth having a look at.

> >  	np->tx.req_prod_pvt = prod;
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> Thanks !

Thanks for the review.

Ian.

> 
> 
