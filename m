From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/2] batman-adv: Delete unnecessary checks before the function
 call "kfree_skb"
Date: Sun, 15 Nov 2015 09:43:26 +0100
Message-ID: <564845AE.8020008@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net>
 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
 <530A086E.8010901@users.sourceforge.net>
 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net>
 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net>
 <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net> <56484502.8000206@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Antonio Quartulli <antonio@meshcoding.com>,
	"David S. Miller" <davem@davemloft.net>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <56484502.8000206@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 15 Nov 2015 08:04:43 +0100

The kfree_skb() function tests whether its argument is NULL and then
returns immediately. Thus the test around the calls is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/batman-adv/main.c           | 2 +-
 net/batman-adv/network-coding.c | 4 +---
 net/batman-adv/send.c           | 3 +--
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index d7f17c1..9e9b8f6 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -1184,7 +1184,7 @@ void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, u8 *src,
 		ret = true;
 
 out:
-	if (skb && !ret)
+	if (!ret)
 		kfree_skb(skb);
 	if (orig_node)
 		batadv_orig_node_free_ref(orig_node);
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index f5276be..c98b0ab 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -244,9 +244,7 @@ static void batadv_nc_path_free_ref(struct batadv_nc_path *nc_path)
  */
 static void batadv_nc_packet_free(struct batadv_nc_packet *nc_packet)
 {
-	if (nc_packet->skb)
-		kfree_skb(nc_packet->skb);
-
+	kfree_skb(nc_packet->skb);
 	batadv_nc_path_free_ref(nc_packet->nc_path);
 	kfree(nc_packet);
 }
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index f664324..782fa33 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -407,8 +407,7 @@ void batadv_schedule_bat_ogm(struct batadv_hard_iface *hard_iface)
 
 static void batadv_forw_packet_free(struct batadv_forw_packet *forw_packet)
 {
-	if (forw_packet->skb)
-		kfree_skb(forw_packet->skb);
+	kfree_skb(forw_packet->skb);
 	if (forw_packet->if_incoming)
 		batadv_hardif_free_ref(forw_packet->if_incoming);
 	if (forw_packet->if_outgoing)
-- 
2.6.2

