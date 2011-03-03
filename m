From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [Lxc-users] Bad checksums and lost packets with macvlan on dummy
Date: Thu, 3 Mar 2011 22:30:08 +0800
Message-ID: <AANLkTimCEgMwUeQ_BBLHDij=t9_uHovgkg3TN1kjYOkb@mail.gmail.com>
References: <20110221150710.GA5651@nord.niifaq.ru> <4D6282DB.2080204@free.fr>
 <20110221153421.GA6602@nord.niifaq.ru> <4D628DC3.9000400@free.fr>
 <20110223170512.GA10277@nord.niifaq.ru> <4D6A6A5F.4030707@free.fr>
 <1298836236.8726.109.camel@edumazet-laptop> <4D6AB578.3010704@free.fr>
 <1298879114.8726.131.camel@edumazet-laptop> <4D6CF4A8.6000205@free.fr>
 <4D6D2402.6020705@trash.net> <4D6D515A.8060707@free.fr> <4D6E23F3.4010402@trash.net>
 <4D6E6A55.6000607@free.fr> <4D6E8686.3000109@trash.net> <4D6E8D80.3090907@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrian Nord <nightnord@gmail.com>,
	lxc-users@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39486 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887Ab1CCOam convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 09:30:42 -0500
Received: by fxm17 with SMTP id 17so1139820fxm.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 06:30:40 -0800 (PST)
In-Reply-To: <4D6E8D80.3090907@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 3, 2011 at 2:33 AM, Daniel Lezcano <daniel.lezcano@free.fr>=
 wrote:
>
> One last question. In the case of broadcast packets with maclvan in b=
ridge
> mode.
> We will have the packets going through each macvlan port and also to =
the
> lower-device, right ?
> For the latter, don't we have a problem if the packet is flagged
> CHECKSUM_UNNECESSARY ?
>
> Shouldn't we restore the ip_summed field before sending through
> dev_queue_xmit ?
>
> ---
> =A0drivers/net/macvlan.c | =A0 =A03 +++
> =A01 file changed, 3 insertions(+)
>
> Index: linux-next/drivers/net/macvlan.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-next.orig/drivers/net/macvlan.c
> +++ linux-next/drivers/net/macvlan.c
> @@ -222,10 +222,13 @@ static int macvlan_queue_xmit(struct sk_
>
> =A0 =A0 =A0 =A0if (vlan->mode =3D=3D MACVLAN_MODE_BRIDGE) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct ethhdr *eth =3D (void *)s=
kb->data;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __u8 ip_summed =3D skb->ip_summed;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->ip_summed; =3D CHECKSUM_UNNECESSAR=
Y;

You added a additional ";".


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
