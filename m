From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 16/43] drivers/net/cxgb3: fix sparse warning: symbol shadows
	an earlier one
Date: Sat, 14 Feb 2009 22:16:04 +0100
Message-ID: <20090214211557.23489.75670.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:59358 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753993AbZBNVQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:16:09 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Move variable declaration as close to usage as possible.

Fix this sparse warning:
  drivers/net/cxgb3/cxgb3_main.c:1586:21: warning: symbol 'cap' shadows an earlier one

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/cxgb3/cxgb3_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index f2c7cc3..0f6062a 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1565,7 +1565,6 @@ static int speed_duplex_to_caps(int speed, int duplex)
 
 static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	int cap;
 	struct port_info *p = netdev_priv(dev);
 	struct link_config *lc = &p->link_config;
 
@@ -1575,7 +1574,7 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		 * being requested.
 		 */
 		if (cmd->autoneg == AUTONEG_DISABLE) {
-			cap = speed_duplex_to_caps(cmd->speed, cmd->duplex);
+			int cap = speed_duplex_to_caps(cmd->speed, cmd->duplex);
 			if (lc->supported & cap)
 				return 0;
 		}

