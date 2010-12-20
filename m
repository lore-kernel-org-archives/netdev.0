From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Mon, 20 Dec 2010 10:21:25 +0100
Message-ID: <1292836885.2800.4.camel@edumazet-laptop>
References: <4D0DEDF9.7020102@itcare.pl>
	 <1292773433.18869.153.camel@edumazet-laptop> <4D0E2E52.3090802@itcare.pl>
	 <AANLkTimMY3D_HssWb=Sw=b3tsxEKACk2QUzFzi-HaC-J@mail.gmail.com>
	 <4D0E6C6D.10806@itcare.pl> <4D0E8416.2030100@gmail.com>
	 <4D0E857E.5060302@gmail.com> <4D0E868F.90005@gmail.com>
	 <4D0F0D73.2080807@itcare.pl>
	 <AANLkTim1YZd0FgunGKN_YPiLW+uExXajwingUkQeW=a=@mail.gmail.com>
	 <1292836097.2800.3.camel@edumazet-laptop>
	 <AANLkTi=R_ZsYgsYd7EkxHRFTKjtLyLQAOYay2nBV=0bK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
	"David S. Miller" <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63932 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241Ab0LTJVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 04:21:30 -0500
Received: by wwa36 with SMTP id 36so2724367wwa.1
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 01:21:29 -0800 (PST)
In-Reply-To: <AANLkTi=R_ZsYgsYd7EkxHRFTKjtLyLQAOYay2nBV=0bK@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 d=C3=A9cembre 2010 =C3=A0 17:11 +0800, Changli Gao a =C3=A9=
crit :
> On Mon, Dec 20, 2010 at 5:08 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le lundi 20 d=C3=A9cembre 2010 =C3=A0 16:56 +0800, Changli Gao a =C3=
=A9crit :
> >
> > This patch cant be right as is.
> >
> >        if (skb_is_gso(skb)) {
> > +               if (skb_shared(skb)) {
> > +                       struct sk_buff *nskb;
> > +
> > +                       nskb =3D skb_clone(skb, GFP_ATOMIC);
> > +                       if (!nskb)
> > +                               return -ENOMEM;
> > +                       kfree_skb(skb); // HERE
> > +                       skb =3D nskb;
> > +               }
> >
> > You free original skb, while caller might dereference it later.
> > So you must pass cloned skb back to caller.
> >
> > (line 6393 :)
> >  count =3D ixgbe_tx_map(adapter, tx_ring, skb, tx_flags, first);
> >
> >
>=20
> Yes, you are right. I just wonder where shared skbs are allowed. Is
> there any rule?
>=20

Shared skbs are allowed for sure (pktgen is a provider of such skbs).


