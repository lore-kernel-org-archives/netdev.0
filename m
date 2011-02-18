From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next-2.6] net: convert bonding to use rx_handler
Date: Fri, 18 Feb 2011 20:58:26 +0100
Message-ID: <1298059106.2425.31.camel@edumazet-laptop>
References: <20110218132524.GC2939@psychotron.redhat.com>
	 <1298035791.6201.56.camel@edumazet-laptop>
	 <20110218141456.GD2939@psychotron.redhat.com>
	 <1298039252.6201.66.camel@edumazet-laptop> <4D5E8655.5070304@trash.net>
	 <20110218145850.GF2939@psychotron.redhat.com> <4D5E953F.6010606@trash.net>
	 <1298045670.6201.73.camel@edumazet-laptop>
	 <20110218184725.GA2602@psychotron.redhat.com>
	 <1298056657.2425.28.camel@edumazet-laptop>
	 <20110218192856.GB2602@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	fubar@us.ibm.com, nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:58625 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758455Ab1BRT6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 14:58:31 -0500
Received: by bwz15 with SMTP id 15so1081020bwz.19
        for <netdev@vger.kernel.org>; Fri, 18 Feb 2011 11:58:29 -0800 (PST)
In-Reply-To: <20110218192856.GB2602@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 f=C3=A9vrier 2011 =C3=A0 20:28 +0100, Jiri Pirko a =C3=A9=
crit :

> Yes I saw this. We would have to do something like:
>=20
> struct skb_rx_context {
> 	struct sk_buff *skb;
> 	struct net_device *orig_dev;
> };
>=20
> static DEFINE_PER_CPU(struct skb_rx_context, skb_rx_context);
>=20
> and then in __netif_receive_skb():
>=20
> struct skb_rx_context *cont =3D __this_cpu_read(skb_rx_context);
>=20
> if (cont->skb !=3D skb) {
> 	cont->skb =3D skb;
> 	orig_dev =3D cont->orig_dev =3D skb->dev;
> } else {
> 	orig_dev =3D cont->orig_dev;
> }
>=20
>=20
> Does this make sense?

Well, yes, something like that, but I think you dont need to keep a
pointer to current skb. (It would not work if one handled/freed, same
'skb pointer' is reused a bit later)

Sorry, I wont have time to look at this right now, its now 21h00 in
=46rance, time to get some time with family ;)

See you !


