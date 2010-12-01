From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: optimize INET input path further
Date: Wed, 01 Dec 2010 18:42:38 +0100
Message-ID: <1291225358.2856.1035.camel@edumazet-laptop>
References: <1291179847.2856.452.camel@edumazet-laptop>
	 <4CF687F3.7030107@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37675 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754972Ab0LARmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 12:42:45 -0500
Received: by wyb28 with SMTP id 28so7200380wyb.19
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 09:42:44 -0800 (PST)
In-Reply-To: <4CF687F3.7030107@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 12:37 -0500, Brian Haley a =C3=
=A9crit :
> On 12/01/2010 12:04 AM, Eric Dumazet wrote:
> >  struct sock_common {
> > -	/*
> > -	 * first fields are not copied in sock_copy()
> > +	/* skc_daddr and skc_rcv_saddr must be grouped :
> > +	 * cf INET_MATCH() and INET_TW_MATCH()
> >  	 */
> > -	union {
> > -		struct hlist_node	skc_node;
> > -		struct hlist_nulls_node skc_nulls_node;
> > -	};
> > -	atomic_t		skc_refcnt;
> > -	int			skc_tx_queue_mapping;
> > +	__be32			skc_daddr;
> > +	__be32			skc_rcv_saddr;
> > =20
> >  	union  {
> >  		unsigned int	skc_hash;
>=20
> Putting IPv4 addresses in sock_common doesn't make it so common anymo=
re :)
>=20
> Is it possible to make this a union so other address families like IP=
v6
> can benefit from this as well, or will that blow the whole cache line
> effect you were trying to achieve?

This might be OK, depending on cache line size and/or arch.

On x86_32 for example, that might even be a good thing, because refcnt
might still be in the first 64bytes of socket.

By the way, ipv6 sock includes inet, so includes ipv4 addresses too, I
only moved them in the 'whole structure'



