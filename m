From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [HELP] ATM: mpc, use-after-free
Date: Mon, 11 Oct 2010 10:18:00 +0200
Message-ID: <1286785081.2737.2.camel@edumazet-laptop>
References: <4CB2C33C.8080109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	linux-atm-general@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>, chas@cmf.nrl.navy.mil
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50314 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731Ab0JKISK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 04:18:10 -0400
In-Reply-To: <4CB2C33C.8080109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 octobre 2010 =C3=A0 09:56 +0200, Jiri Slaby a =C3=A9crit :
> Hi,
>=20
> Stanse found this use-after-free:
>=20
> static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
> {
> ...
>         new_skb =3D skb_realloc_headroom(skb, eg->ctrl_info.DH_length=
);
>=20
>         dev_kfree_skb_any(skb);
>=20
> FREE    ^^^^^^^^^^^^^^^^^^^^^^^
>=20
>         if (new_skb =3D=3D NULL) {
>                 mpc->eg_ops->put(eg);
>                 return;
>         }
>         skb_push(new_skb, eg->ctrl_info.DH_length);
>         skb_copy_to_linear_data(new_skb, eg->ctrl_info.DLL_header,
>                                 eg->ctrl_info.DH_length);
>  ...
>         memset(ATM_SKB(skb), 0, sizeof(struct atm_skb_data));
>=20
> USE            ^^^^^^^^^^^^
>=20
>         netif_rx(new_skb);
>=20
> I guess it should be ATM_SKB(new_skb), right?

Yes

-	memset(ATM_SKB(skb), 0, sizeof(struct atm_skb_data));
+	memset(ATM_SKB(new_skb), 0, sizeof(struct atm_skb_data));

>=20
> The two problems are:
> 1) obvious use-after-free
> 2) ?data leak, since we don't erase the right memory?
>=20
> thanks,

Indeed, please submit a formal patch ?

Thanks


