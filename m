From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Generalized TTL Security Mechanism
Date: Fri, 19 Mar 2010 09:21:11 +0100
Message-ID: <1268986871.3048.9.camel@edumazet-laptop>
References: <20100110220034.4d46ba8a@nehalam>
	 <alpine.LRH.2.00.1003180833420.24946@netcore.fi>
	 <20100318105939.57f8d377@nehalam>
	 <alpine.LRH.2.00.1003190837210.6428@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Pekka Savola <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:35217 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280Ab0CSIVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 04:21:16 -0400
Received: by bwz1 with SMTP id 1so2741784bwz.21
        for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 01:21:14 -0700 (PDT)
In-Reply-To: <alpine.LRH.2.00.1003190837210.6428@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 mars 2010 =C3=A0 09:58 +0200, Pekka Savola a =C3=A9crit =
:
>=20
> > But any application using GTSM should be setting IP_TTL socket
> option
> > to set send TTL. But, not sure if Linux TCP ever sends ICMP
> > for existing sessions at all.
>=20
> Thanks, Stephen!  It's nice to see at least one compliant RFC5082=20
> implementation ;-)
>=20
> Good point that no one should should probably even be sending ICMP=20
> messages for TCP sockets, but on receive side the checks are
> important=20
> :-)

This requires that any router in the path between the client and server
also respects the MINTTL when sending ICMP. Not sure how practical it
is...

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 70df409..a9d3ba5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -367,6 +367,9 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 	if (sock_owned_by_user(sk))
 		NET_INC_STATS_BH(net, LINUX_MIB_LOCKDROPPEDICMPS);
=20
+	if (iph->ttl < inet_sk(sk)->min_ttl)
+		goto out;
+
 	if (sk->sk_state =3D=3D TCP_CLOSE)
 		goto out;
=20


