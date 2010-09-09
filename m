From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: inet_add_protocol() can use cmpxchg()
Date: Thu, 9 Sep 2010 17:38:07 +0200
Message-ID: <20100909153807.GA2055@del.dom.local>
References: <20100909064222.GA6951@ff.dom.local>
 <1284015345.2428.37.camel@edumazet-laptop>
 <20100909070926.GB6951@ff.dom.local>
 <20100909072453.GA7383@ff.dom.local>
 <20100909090816.GA7450@ff.dom.local>
 <1284024237.2589.15.camel@edumazet-laptop>
 <20100909095920.GB8404@ff.dom.local>
 <1284037058.2589.169.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jesse@nicira.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51226 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023Ab0IIPiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 11:38:14 -0400
Received: by eyb6 with SMTP id 6so963625eyb.19
        for <netdev@vger.kernel.org>; Thu, 09 Sep 2010 08:38:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1284037058.2589.169.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 09, 2010 at 02:57:38PM +0200, Eric Dumazet wrote:
> Le jeudi 09 septembre 2010 ?? 09:59 +0000, Jarek Poplawski a =E9crit =
:
>=20
> > Btw, I wonder if for readability and debuging it shouldn't be made
> > generic as rcu_cmpxchg_pointer() etc.?
>=20
> There are a lot of things to do in this area (with proper __rcu spars=
e
> annotations, this can be not very readable ...)

Well, this is more than I could dream ;-) The main point to me was
autodocumentation in use, similarly to rcu_assign_pointer(). But, of
course, with the description below it's much better.

Thanks,
Jarek P.

>=20
> /**
>  * rcu_cmpxchg - atomic compare and exchange, SMP & rcu safe
>  * @p: pointer to value
>  * @old: old value
>  * @new: new value
>  *
>  * Equivalent to :
>  *    ATOMIC_BEGIN
>  *     ret =3D *p;
>  *     if (ret =3D=3D old)
>  *             rcu_assign_pointer(*p, new);
>  *    ATOMIC_END
>  *    return ret;
>  *
>  * cmpxpchg() contains full memory barriers, so can be used
>  * in rcu write side without additional smp_wmb() barrier
>  */
> #define rcu_cmpxchg(p, old, new) cmpxchg(p, old, new)
>=20
>=20
> const struct net_protocol __rcu *
>         inet_protos[MAX_INET_PROTOS] __read_mostly;
>=20
> ...
>=20
> return !rcu_cmpxchg(&inet_protos[hash],=20
>                     NULL,
>                     (const struct net_protocol __force __rcu *)prot) =
?
> 		0 : -1;
>=20
> ...
>=20

