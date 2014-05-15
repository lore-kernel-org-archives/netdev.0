From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH] ipv4: ip_tunnels: disable dst cache for nbma gre tunnels
Date: Thu, 15 May 2014 11:35:17 +0300
Message-ID: <1400142917-1849-1-git-send-email-timo.teras@iki.fi>
References: <20140424151647.2a917ff1@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:44183 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167AbaEOIfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 04:35:12 -0400
Received: by mail-lb0-f179.google.com with SMTP id c11so519320lbj.24
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 01:35:10 -0700 (PDT)
In-Reply-To: <20140424151647.2a917ff1@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The connected check fails to check for ip_gre nbma mode tunnels
properly. ip_gre creates temporary tnl_params with daddr specified
to pass-in the actual target on per-packet basis from neighbor
layer. Detect these tunnels by inspecting the actual tunnel
configuration instead.

=46ixes: 7d442fab0a67 ("ipv4: Cache dst in tunnels")
Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
Cc: Tom Herbert <therbert@google.com>
Cc: Eric Dumazet <edumazet@google.com>
---
Should go to 3.14-stable too.

(This does not fix all NBMA GRE regressions in 3.14.
 I'm also getting weird oopses from GRO; will post soon more info.)

 net/ipv4/ip_tunnel.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index e77381d..100caf5 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -538,9 +538,10 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct ne=
t_device *dev,
 	unsigned int max_headroom;	/* The extra header space needed */
 	__be32 dst;
 	int err;
-	bool connected =3D true;
+	bool connected;
=20
 	inner_iph =3D (const struct iphdr *)skb_inner_network_header(skb);
+	connected =3D (tunnel->daddr !=3D 0);
=20
 	dst =3D tnl_params->daddr;
 	if (dst =3D=3D 0) {
--=20
1.9.3
