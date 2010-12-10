From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: unable to handle kernel NULL pointer dereference in skb_dequeue
Date: Fri, 10 Dec 2010 21:51:04 +0200
Message-ID: <201012102151.04983.nuclearcat@nuclearcat.com>
References: <0fe401cb92e7$85ba2260$912e6720$@si> <aa43945b38cee751a8231084866b074d@192.168.253.23> <1291387595.2897.350.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrej Ota <andrej@ota.si>, linux-kernel@vger.kernel.org,
	gvs@zemos.net, Rami Rosen <ramirose@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291387595.2897.350.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 03 December 2010 16:46:35 Eric Dumazet wrote:
> Le vendredi 03 d=C3=A9cembre 2010 =C3=A0 15:37 +0100, Andrej Ota a =C3=
=A9crit :
> > >> Patch that works for me is below. Now I only hope I haven't
> > >> (re)introduced a memory leak...
> > >=20
> > > Problem comes from commit 55c95e738da85 (fix return value of
> > > __pppoe_xmit() method)
> > >=20
> > > I am not sure patch is OK
> >=20
> > Me neither. That's why I wrote "works for me". All I dare say is th=
at it
> > works better than current code and is probably no worse than it was
> > before above mentioned commit. Apart from that, there is no point i=
n
> > having return value for __pppoe_xmit if return value isn't needed.
> >=20
> > Easiest way of triggering this BUG is by terminating PPPoE on the s=
erver
> > side, which then hits "if (!dev) { goto abort; }". This in turn cal=
ls
> > "kfree_skb(skb); return 0;" which returns to pppoe_rcv_core which t=
hen
> > goto-s to "abort_put" which again calls "kfree_skb(skb)". Voila the=
 bug.
> >=20
> > I don't know how to trigger "if (skb_cow_head(skb, ..." to see if I=
 have
> > just caused another BUG. However, if I read file comments at the to=
p, I
> > see a comment from 19/07/01 stating that I have to delete original =
skb
> > if code succeeds and never delete it on failure. About the skb copy
> > mentioned in the same comment, I don't know. 2001 was many commits =
ago.
>=20
> Well, all I wanted to say was that _I_ was not sure, but probably oth=
er
> network guys have a better diagnostic.
>=20
> Rami, could you re-explain the rationale of your patch ?
>=20
> Thanks
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Is there any plans to queue any patch to stable?
pppoe is almost dead in 2.6.36.*
