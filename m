From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 v4 00/14] l2tp: Introduce L2TPv3 support
Date: Sun, 04 Apr 2010 09:54:28 +0200
Message-ID: <1270367668.1971.3.camel@edumazet-laptop>
References: <20100402161822.11367.70454.stgit@bert.katalix.com>
	 <20100403.142522.01040744.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:35643 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509Ab0DDHye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 03:54:34 -0400
Received: by bwz1 with SMTP id 1so2272387bwz.21
        for <netdev@vger.kernel.org>; Sun, 04 Apr 2010 00:54:32 -0700 (PDT)
In-Reply-To: <20100403.142522.01040744.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 03 avril 2010 =C3=A0 14:25 -0700, David Miller a =C3=A9crit :
> From: James Chapman <jchapman@katalix.com>
> Date: Fri, 02 Apr 2010 17:18:23 +0100
>=20
> > This patch series adds L2TPv3 support. It splits the existing pppol=
2tp
> > driver to separate its L2TP and PPP parts, then adds new L2TPv3
> > functionality. The patches implement a new socket family for L2TPv3=
 IP
> > encapsulation, expose virtual netdevices for each L2TPv3 ethernet
> > pseudowire and add a netlink interface.
>=20
> Ok I'm going to toss this into net-next-2.6, we have time to
> fixup any remaining issues people might discover.
>=20

[PATCH net-next-2.6] l2tp: unmanaged L2TPv3 tunnels fixes

=46ollowup to commit 789a4a2c=20
(l2tp: Add support for static unmanaged L2TPv3 tunnels)

One missing init in l2tp_tunnel_sock_create() could access random kerne=
l
memory, and a bit field should be unsigned.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/l2tp/l2tp_core.c |    2 +-
 net/l2tp/l2tp_core.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 13ed85b..98dfcce 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1227,7 +1227,7 @@ static int l2tp_tunnel_sock_create(u32 tunnel_id,=
 u32 peer_tunnel_id, struct l2t
 	int err =3D -EINVAL;
 	struct sockaddr_in udp_addr;
 	struct sockaddr_l2tpip ip_addr;
-	struct socket *sock;
+	struct socket *sock =3D NULL;
=20
 	switch (cfg->encap) {
 	case L2TP_ENCAPTYPE_UDP:
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 91b1b9c..f0f318e 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -152,7 +152,7 @@ struct l2tp_tunnel_cfg {
 	struct in_addr		peer_ip;
 	u16			local_udp_port;
 	u16			peer_udp_port;
-	int			use_udp_checksums:1;
+	unsigned int		use_udp_checksums:1;
 };
=20
 struct l2tp_tunnel {


