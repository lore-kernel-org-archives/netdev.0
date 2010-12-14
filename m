From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6] net: fix nulls list corruptions in
 sk_prot_alloc
Date: Tue, 14 Dec 2010 17:19:17 +0100
Message-ID: <1292343557.5934.22.camel@edumazet-laptop>
References: <1292341443-18360-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Leonard Crestez <lcrestez@ixiacom.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46127 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758112Ab0LNQTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 11:19:22 -0500
Received: by wyb28 with SMTP id 28so618313wyb.19
        for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 08:19:21 -0800 (PST)
In-Reply-To: <1292341443-18360-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 d=C3=A9cembre 2010 =C3=A0 17:44 +0200, Octavian Purdila a =C3=
=A9crit :
> Special care is taken inside sk_port_alloc to avoid overwriting
> skc_node/skc_nulls_node. We should also avoid overwriting
> skc_bind_node/skc_portaddr_node.
>=20
> The patch fixes the following crash:
>=20
>  BUG: unable to handle kernel paging request at fffffffffffffff0
>  IP: [<ffffffff812ec6dd>] udp4_lib_lookup2+0xad/0x370
>  [<ffffffff812ecc22>] __udp4_lib_lookup+0x282/0x360
>  [<ffffffff812ed63e>] __udp4_lib_rcv+0x31e/0x700
>  [<ffffffff812bba45>] ? ip_local_deliver_finish+0x65/0x190
>  [<ffffffff812bbbf8>] ? ip_local_deliver+0x88/0xa0
>  [<ffffffff812eda35>] udp_rcv+0x15/0x20
>  [<ffffffff812bba45>] ip_local_deliver_finish+0x65/0x190
>  [<ffffffff812bbbf8>] ip_local_deliver+0x88/0xa0
>  [<ffffffff812bb2cd>] ip_rcv_finish+0x32d/0x6f0
>  [<ffffffff8128c14c>] ? netif_receive_skb+0x99c/0x11c0
>  [<ffffffff812bb94b>] ip_rcv+0x2bb/0x350
>  [<ffffffff8128c14c>] netif_receive_skb+0x99c/0x11c0
>=20
> Signed-off-by: Leonard Crestez <lcrestez@ixiacom.com>
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> ---

Hmm very good catch, but why a so invasive patch ?

Only udp needs a special care.

Other protocols could use the default 'cleaner', you dont need to force
them to use the default ;)

Unless you want to fix another bug, not mentioned in Changelog ?



