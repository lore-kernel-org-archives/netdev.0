From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: increase skb->users instead of skb_clone()
Date: Thu, 16 Dec 2010 15:30:57 +0100
Message-ID: <1292509857.2883.190.camel@edumazet-laptop>
References: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com>
	 <1292483902.2603.62.camel@edumazet-laptop>
	 <AANLkTi=BX8AMaiwV3aDAVqRA=br00eRo-42vPNwZfwS6@mail.gmail.com>
	 <AANLkTim--M0TvW9oUi0UO6Ej_8aLezneQsdRx7X0CXDt@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Xinan Tang <xinan.tang@intel.com>, netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64687 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756088Ab0LPObD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 09:31:03 -0500
Received: by wyb28 with SMTP id 28so2557004wyb.19
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 06:31:02 -0800 (PST)
In-Reply-To: <AANLkTim--M0TvW9oUi0UO6Ej_8aLezneQsdRx7X0CXDt@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 22:20 +0800, Junchang Wang a =C3=A9=
crit :
> On Thu, Dec 16, 2010 at 3:23 PM, Changli Gao <xiaosuo@gmail.com> wrot=
e:
>=20
> >> You beat me, but I was thinking of a different way, adding a new
> >> pt_prev->xmit_func(), handling all the details (no need for atomic=
 ops
> >> on skb users if packet is not delivered at all).
> >>
> >> By the way, your patch is not 100% safe/OK, because af_packet rcv(=
)
> >> handler writes on skb (skb_pull() and all)
> >>
> >
> > But af_packet_rcv() restores skbs at last.
> >
> >        if (skb_head !=3D skb->data && skb_shared(skb)) {
> >                skb->data =3D skb_head;
> >                skb->len =3D skb_len;
> >        }
> >
> If af packet_rcv invokes skb_clone, this skb is differ from the origi=
nal one.
> Eric's warning is right.

It was a false alarm.

If packet_rcv() invokes skb_clone(), skb still points to original skb.
No worry.


