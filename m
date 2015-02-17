From: Joe Perches <joe@perches.com>
Subject: [PATCH] batman-adv: Remove uses of return value of seq_printf
Date: Mon, 16 Feb 2015 17:31:39 -0800
Message-ID: <1424136699.8287.10.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "b.a.t.m.a.n" <b.a.t.m.a.n@lists.open-mesh.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This function is soon going to return void so remove the
return value use.

Convert the return value to test seq_has_overflowed() instead.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/batman-adv/gateway_client.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 27649e8..a0876ea 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -592,15 +592,16 @@ static int batadv_write_buffer_text(struct batadv_priv *bat_priv,
 
 	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
 
-	ret = seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %u.%u/%u.%u MBit\n",
-			 (curr_gw == gw_node ? "=>" : "  "),
-			 gw_node->orig_node->orig,
-			 router_ifinfo->bat_iv.tq_avg, router->addr,
-			 router->if_incoming->net_dev->name,
-			 gw_node->bandwidth_down / 10,
-			 gw_node->bandwidth_down % 10,
-			 gw_node->bandwidth_up / 10,
-			 gw_node->bandwidth_up % 10);
+	seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %u.%u/%u.%u MBit\n",
+		   (curr_gw == gw_node ? "=>" : "  "),
+		   gw_node->orig_node->orig,
+		   router_ifinfo->bat_iv.tq_avg, router->addr,
+		   router->if_incoming->net_dev->name,
+		   gw_node->bandwidth_down / 10,
+		   gw_node->bandwidth_down % 10,
+		   gw_node->bandwidth_up / 10,
+		   gw_node->bandwidth_up % 10);
+	ret = seq_has_overflowed(seq);
 
 	if (curr_gw)
 		batadv_gw_node_free_ref(curr_gw);
