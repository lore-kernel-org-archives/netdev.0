From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use jump_label to shortcut RPS if not setup
Date: Thu, 17 Nov 2011 12:08:20 +0100
Message-ID: <1321528100.2751.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1321526027.2751.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:40811 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756669Ab1KQLIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 06:08:25 -0500
Received: by bke11 with SMTP id 11so1821868bke.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 03:08:23 -0800 (PST)
In-Reply-To: <1321526027.2751.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 11:33 +0100, Eric Dumazet a =C3=A9crit=
 :
> Most machines dont use RPS/RFS, and pay a fair amount of instructions=
 in
> netif_receive_skb() / get_rps_cpu() just to discover RPS/RFS is not
> setup.
>=20
> Add a jump_label named rps_needed.
>=20
> If no device rps_map or global rps_sock_flow_table is setup,
> netif_receive_skb() does a single instruction instead of many ones,
> including conditional jumps.
>=20
> jmp +0    (if CONFIG_JUMP_LABEL=3Dy)
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Tom Herbert <therbert@google.com>
> ---

I'll send a V2 to take care of netif_rx() as well.
