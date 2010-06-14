From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2] net: deliver skbs on inactive slaves to exact
	matches
Date: Mon, 14 Jun 2010 17:10:12 +0300
Message-ID: <20100614141012.GA25547@redhat.com>
References: <20100603193011.4916.12354.stgit@jf-dev2-dcblab> <20100614132120.GA24785@redhat.com> <1276522483.2478.88.camel@edumazet-laptop> <1276522708.2478.89.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>, fubar@us.ibm.com,
	davem@davemloft.net, nhorman@tuxdriver.com,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49481 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751097Ab0FNOPL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jun 2010 10:15:11 -0400
Content-Disposition: inline
In-Reply-To: <1276522708.2478.89.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 14, 2010 at 03:38:28PM +0200, Eric Dumazet wrote:
> Le lundi 14 juin 2010 =E0 15:34 +0200, Eric Dumazet a =E9crit :
>=20
> > [PATCH] net: fix deliver_no_wcard regression on loopback device
> >=20
> > deliver_no_wcard is not being set in skb_copy_header.
> > In the skb_cloned case it is not being cleared and
> > may cause the skb to be dropped when the loopback device
> > pushes it back up the stack.
> >=20
> > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> > Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Oh I forgot :
>=20
> Tested-by: Markus Trippelsdorf <markus@trippelsdorf.de>

Grr. Could have saved myself a bit of time if I guessed
it's related.

> > ---
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 9f07e74..bcf2fa3 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -532,6 +532,7 @@ static void __copy_skb_header(struct sk_buff *n=
ew, const struct sk_buff *old)
> >  	new->ip_summed		=3D old->ip_summed;
> >  	skb_copy_queue_mapping(new, old);
> >  	new->priority		=3D old->priority;
> > +	new->deliver_no_wcard	=3D old->deliver_no_wcard;
> >  #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
> >  	new->ipvs_property	=3D old->ipvs_property;
> >  #endif
> >=20
>=20
