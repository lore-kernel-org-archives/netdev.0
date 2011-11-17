From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: use jump_label to shortcut RPS if not
 setup
Date: Thu, 17 Nov 2011 22:34:49 +0100
Message-ID: <1321565689.2444.5.camel@edumazet-laptop>
References: <1321535606.2751.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:64415 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752947Ab1KQVey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 16:34:54 -0500
Received: by eye27 with SMTP id 27so2518183eye.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 13:34:53 -0800 (PST)
In-Reply-To: <1321535606.2751.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 14:13 +0100, Eric Dumazet a =C3=A9crit=
 :
> Most machines dont use RPS/RFS, and pay a fair amount of instructions=
 in
> netif_receive_skb() / netif_rx() / get_rps_cpu() just to discover
> RPS/RFS is not setup.
>=20
> Add a jump_label named rps_needed.
>=20
> If no device rps_map or global rps_sock_flow_table is setup,
> netif_receive_skb() / netif_rx() do a single instruction instead of m=
any
> ones, including conditional jumps.
>=20
> jmp +0    (if CONFIG_JUMP_LABEL=3Dy)
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Tom Herbert <therbert@google.com>

I wonder if we could use this jump_label infrastructure to shortcut
expensive netfilter nf_hook_slow() / nf_iterate on empty
tables/chains...
