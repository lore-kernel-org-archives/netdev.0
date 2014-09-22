From: Mario Pirker <mariopirker@hotmail.com>
Subject: [PATCH] batman-adv: fix potential NULL pointer dereferencing
Date: Mon, 22 Sep 2014 11:11:19 +0200
Message-ID: <DUB123-W2663266CEA8296935E9450A0B30@phx.gbl>
Reply-To: <mpirker@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "mareklindner@neomailbox.ch" <mareklindner@neomailbox.ch>,
	"sw@simonwunderlich.de" <sw@simonwunderlich.de>,
	"antonio@meshcoding.com" <antonio@meshcoding.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom b451e7317148e18bf6c5c8fd747d79ab34260354 Mon Sep 17 00:00:00 200=
1
=46rom: Mario Pirker <mario.pirker@kellogg.ox.ac.uk>
Date: Tue, 16 Sep 2014 17:55:13 +0200
Subject: [PATCH] batman-adv: fix potential NULL pointer dereferencing

The call batadv_gw_node_get may return NULL. The return value has to
be sanity checked before the pointer is dereferenced.

Signed-off-by: Mario Pirker <mariopirker@hotmail.com>
---
=A0net/batman-adv/gateway_client.c | 5 +++++
=A01 file changed, 5 insertions(+)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_c=
lient.c
index 90cff58..7ee0913 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -810,6 +810,11 @@ bool batadv_gw_out_of_range(struct batadv_priv *ba=
t_priv,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
=A0
=A0 =A0 =A0 =A0 gw_node =3D batadv_gw_node_get(bat_priv, orig_dst_node)=
;
+
+ =A0 =A0 =A0 /* gw_node can be NULL. We need to check before dereferen=
cing */
+ =A0 =A0 =A0 if (gw_node =3D=3D NULL)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
+
=A0 =A0 =A0 =A0 if (!gw_node->bandwidth_down =3D=3D 0)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
=A0
--=A0
1.8.1.4 		 	   		  --
To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
