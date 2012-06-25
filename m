From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 12/20] batman-adv: Prefix gateway_common local static functions with batadv_
Date: Mon, 25 Jun 2012 08:54:36 +0200
Message-ID: <1340607284-29950-13-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:30541 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579Ab2FYGyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:54:49 -0400
In-Reply-To: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

All non-static symbols of batman-adv were prefixed with batadv_ to avoid
collisions with other symbols of the kernel. Other symbols of batman-adv
should use the same prefix to keep the naming scheme consistent.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/gateway_common.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 3700562c..6edf37f 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -22,7 +22,7 @@
 #include "gateway_client.h"
 
 /* calculates the gateway class from kbit */
-static void kbit_to_gw_bandwidth(int down, int up, long *gw_srv_class)
+static void batadv_kbit_to_gw_bandwidth(int down, int up, long *gw_srv_class)
 {
 	int mdown = 0, tdown, tup, difference;
 	uint8_t sbit, part;
@@ -73,8 +73,8 @@ void batadv_gw_bandwidth_to_kbit(uint8_t gw_srv_class, int *down, int *up)
 	*up = ((upart + 1) * (*down)) / 8;
 }
 
-static bool parse_gw_bandwidth(struct net_device *net_dev, char *buff,
-			       int *up, int *down)
+static bool batadv_parse_gw_bandwidth(struct net_device *net_dev, char *buff,
+				      int *up, int *down)
 {
 	int ret, multi = 1;
 	char *slash_ptr, *tmp_ptr;
@@ -142,7 +142,7 @@ ssize_t batadv_gw_bandwidth_set(struct net_device *net_dev, char *buff,
 	int up = 0, down = 0;
 	bool ret;
 
-	ret = parse_gw_bandwidth(net_dev, buff, &up, &down);
+	ret = batadv_parse_gw_bandwidth(net_dev, buff, &up, &down);
 	if (!ret)
 		goto end;
 
@@ -152,7 +152,7 @@ ssize_t batadv_gw_bandwidth_set(struct net_device *net_dev, char *buff,
 	if (!up)
 		up = down / 5;
 
-	kbit_to_gw_bandwidth(down, up, &gw_bandwidth_tmp);
+	batadv_kbit_to_gw_bandwidth(down, up, &gw_bandwidth_tmp);
 
 	/* the gw bandwidth we guessed above might not match the given
 	 * speeds, hence we need to calculate it back to show the number
-- 
1.7.9.4
