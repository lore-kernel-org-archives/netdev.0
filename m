From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] mlx4_en: dont change mac_header on xmit
Date: Sun, 4 Mar 2012 13:19:33 +0200
Message-ID: <CAJZOPZKAwrx-u_onDQCCxipkLPdZkPE6cokRtZOa1uRZiZTYug@mail.gmail.com>
References: <1330167065.2462.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:58696 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752845Ab2CDLTe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 06:19:34 -0500
Received: by pbcun15 with SMTP id un15so1752743pbc.19
        for <netdev@vger.kernel.org>; Sun, 04 Mar 2012 03:19:33 -0800 (PST)
In-Reply-To: <1330167065.2462.53.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> + =A0 =A0 =A0 ethh =3D (struct ethhdr *)skb->data;
> + =A0 =A0 =A0 tx_desc->ctrl.srcrb_flags16[0] =3D get_unaligned((u16 *=
)ethh->h_dest);
> + =A0 =A0 =A0 tx_desc->ctrl.imm =3D get_unaligned((u32 *)(ethh->h_des=
t + 2));

Hi Eric,

commit 622121719934f60378279eb440d3cec2fc3176d2 of your triggers the
below sparse
warnings, could you advise what would be the correct way to fix that ou=
t?

Or.

 CHECK   drivers/net/ethernet/mellanox/mlx4/en_tx.c
drivers/net/ethernet/mellanox/mlx4/en_tx.c:689:40: warning: incorrect
type in assignment (different base types)
drivers/net/ethernet/mellanox/mlx4/en_tx.c:689:40:    expected
restricted __be16 <noident>
drivers/net/ethernet/mellanox/mlx4/en_tx.c:689:40:    got unsigned
short [unsigned] <noident>
drivers/net/ethernet/mellanox/mlx4/en_tx.c:690:27: warning: incorrect
type in assignment (different base types)
drivers/net/ethernet/mellanox/mlx4/en_tx.c:690:27:    expected
restricted __be32 [usertype] imm
drivers/net/ethernet/mellanox/mlx4/en_tx.c:690:27:    got unsigned int
[unsigned] <noident>
