From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next] bridge: multicast router list manipulation
Date: Wed, 28 Apr 2010 01:11:52 +0200
Message-ID: <y2ne2d7436a1004271611h5dc5f184gcbbc6748839c3c58@mail.gmail.com>
References: <20100228054012.GA7583@gondor.apana.org.au>
	 <E1NlbuX-00021m-Bq@gondolin.me.apana.org.au>
	 <20100427101311.2f445227@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62395 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486Ab0D0XLy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 19:11:54 -0400
Received: by wye20 with SMTP id 20so335710wye.19
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 16:11:52 -0700 (PDT)
In-Reply-To: <20100427101311.2f445227@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/4/27 Stephen Hemminger <shemminger@vyatta.com>:
> I prefer that the hlist be only accessed through the hlist macro
> objects. Explicit twiddling of links (especially with RCU) exposes
> the code to future bugs.
[...]
> - =A0 =A0 =A0 port->rlist.pprev =3D h;
> - =A0 =A0 =A0 port->rlist.next =3D p;
> - =A0 =A0 =A0 rcu_assign_pointer(*h, &port->rlist);
> - =A0 =A0 =A0 if (p)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 p->pprev =3D &port->rlist.next;
> + =A0 =A0 =A0 hlist_for_each_entry(p, n, &br->router_list, rlist) {

Shouldn't this be hlist_for_each_entry_rcu?

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((unsigned long) port >=3D (unsigned=
 long) p) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_add_before_rcu(n,=
 &port->rlist);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 last =3D n;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (last)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_add_after_rcu(last, &port->rlist)=
;
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_add_head_rcu(&port->rlist, &br->r=
outer_list);
> =A0}
>
[...]

Best Regards,
Micha=B3 Miros=B3aw
