From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: dont drop MTU reduction indications
Date: Mon, 23 Jul 2012 00:59:03 -0700 (PDT)
Message-ID: <20120723.005903.2179205107462793469.davem@davemloft.net>
References: <1343029732.2626.10234.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, nanditad@google.com, ncardwell@google.com,
	maze@google.com, tore@fud.no, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42875 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389Ab2GWH7E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 03:59:04 -0400
In-Reply-To: <1343029732.2626.10234.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Jul 2012 09:48:52 +0200

> From: Eric Dumazet <edumazet@google.com>
>=20
> ICMP messages generated in output path if frame length is bigger than
> mtu are actually lost because socket is owned by user (doing the xmit=
)
>=20
> One example is the ipgre_tunnel_xmit() calling=20
> icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
>=20
> We had a similar case fixed in commit a34a101e1e6 (ipv6: disable GSO =
on
> sockets hitting dst_allfrag).
>=20
> Problem of such fix is that it relied on retransmit timers, so short =
tcp
> sessions paid a too big latency increase price.
>=20
> This patch uses the tcp_release_cb() infrastructure so that MTU
> reduction messages (ICMP messages) are not lost, and no extra delay
> is added in TCP transmits.
>=20
> Reported-by: Maciej =AFenczykowski <maze@google.com>
> Diagnosed-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
