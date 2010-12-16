From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: increase skb->users instead of skb_clone()
Date: Thu, 16 Dec 2010 08:50:08 +0100
Message-ID: <1292485808.2603.78.camel@edumazet-laptop>
References: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com>
	 <1292483902.2603.62.camel@edumazet-laptop>
	 <AANLkTi=BX8AMaiwV3aDAVqRA=br00eRo-42vPNwZfwS6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Junchang Wang <junchangwang@gmail.com>,
	Xinan Tang <xinan.tang@intel.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46556 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972Ab0LPHuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 02:50:14 -0500
Received: by wwa36 with SMTP id 36so2135715wwa.1
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 23:50:13 -0800 (PST)
In-Reply-To: <AANLkTi=BX8AMaiwV3aDAVqRA=br00eRo-42vPNwZfwS6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 15:23 +0800, Changli Gao a =C3=A9=
crit :
> On Thu, Dec 16, 2010 at 3:18 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> >
> > You beat me, but I was thinking of a different way, adding a new
> > pt_prev->xmit_func(), handling all the details (no need for atomic =
ops
> > on skb users if packet is not delivered at all).
> >
> > By the way, your patch is not 100% safe/OK, because af_packet rcv()
> > handler writes on skb (skb_pull() and all)
> >
>=20
> But af_packet_rcv() restores skbs at last.
>=20
>         if (skb_head !=3D skb->data && skb_shared(skb)) {
>                 skb->data =3D skb_head;
>                 skb->len =3D skb_len;
>         }
>=20

Thats right, your patch seems fine, thanks !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



