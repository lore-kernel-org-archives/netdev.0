From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] drivers/net/wireless/ipw2x00: use strlcpy instead of strncpy
Date: Sat, 05 Jan 2013 21:41:17 +0800
Message-ID: <50E82D7D.4090107@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: stas.yakovlev@gmail.com, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:48715 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755664Ab3AENkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 08:40:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  The fields must be null-terminated, or IPW_DEBUG_ASSOC will cause issue.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 drivers/net/wireless/ipw2x00/ipw2200.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 844f201..c85261b 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -5558,7 +5558,7 @@ static int ipw_find_adhoc_network(struct ipw_priv *priv,
 			    min(network->ssid_len, priv->essid_len)))) {
 			char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
 
-			strncpy(escaped,
+			strlcpy(escaped,
 				print_ssid(ssid, network->ssid,
 					   network->ssid_len),
 				sizeof(escaped));
@@ -5771,7 +5771,7 @@ static int ipw_best_network(struct ipw_priv *priv,
 		     memcmp(network->ssid, priv->essid,
 			    min(network->ssid_len, priv->essid_len)))) {
 			char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
-			strncpy(escaped,
+			strlcpy(escaped,
 				print_ssid(ssid, network->ssid,
 					   network->ssid_len),
 				sizeof(escaped));
@@ -5788,7 +5788,7 @@ static int ipw_best_network(struct ipw_priv *priv,
 	 * testing everything else. */
 	if (match->network && match->network->stats.rssi > network->stats.rssi) {
 		char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
-		strncpy(escaped,
+		strlcpy(escaped,
 			print_ssid(ssid, network->ssid, network->ssid_len),
 			sizeof(escaped));
 		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded because "
-- 
1.7.10.4
