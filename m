From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 38/43] drivers/net/wireless: fix sparse warnings: symbol
	shadows an earlier one
Date: Sat, 14 Feb 2009 22:49:09 +0100
Message-ID: <20090214214852.24377.70239.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f25.google.com ([209.85.220.25]:64702 "EHLO
	mail-fx0-f25.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755559AbZBNVtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:49:15 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact:
  Move variable closer to usage resp.
  remove redundant variables resp.
  rename function scope variable.

Fix this sparse warnings:
  drivers/net/wireless/airo.c:3840:29: warning: symbol 'i' shadows an earlier one
  drivers/net/wireless/airo.c:3751:13: originally declared here
  drivers/net/wireless/airo.c:3847:29: warning: symbol 'i' shadows an earlier one
  drivers/net/wireless/airo.c:3751:13: originally declared here
  drivers/net/wireless/airo.c:3861:21: warning: symbol 'i' shadows an earlier one
  drivers/net/wireless/airo.c:3751:13: originally declared here
  drivers/net/wireless/wavelan.c:43:13: warning: symbol 'irq' shadows an earlier one
  drivers/net/wireless/wavelan.p.h:692:17: originally declared here

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/wireless/airo.c    |    4 +---
 drivers/net/wireless/wavelan.c |    8 ++++----
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 308603e..220f00b 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -3748,7 +3748,6 @@ static u16 setup_card(struct airo_info *ai, u8 *mac, int lock)
 	Cmd cmd;
 	Resp rsp;
 	int status;
-	int i;
 	SsidRid mySsid;
 	__le16 lastindex;
 	WepKeyRid wkr;
@@ -3790,6 +3789,7 @@ static u16 setup_card(struct airo_info *ai, u8 *mac, int lock)
 	if (lock)
 		up(&ai->sem);
 	if (ai->config.len == 0) {
+		int i;
 		tdsRssiRid rssi_rid;
 		CapabilityRid cap_rid;
 
@@ -3837,14 +3837,12 @@ static u16 setup_card(struct airo_info *ai, u8 *mac, int lock)
 		/* Check to see if there are any insmod configured
 		   rates to add */
 		if ( rates[0] ) {
-			int i = 0;
 			memset(ai->config.rates,0,sizeof(ai->config.rates));
 			for( i = 0; i < 8 && rates[i]; i++ ) {
 				ai->config.rates[i] = rates[i];
 			}
 		}
 		if ( basic_rate > 0 ) {
-			int i;
 			for( i = 0; i < 8; i++ ) {
 				if ( ai->config.rates[i] == basic_rate ||
 				     !ai->config.rates ) {
diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
index 8326793..688bdea 100644
--- a/drivers/net/wireless/wavelan.c
+++ b/drivers/net/wireless/wavelan.c
@@ -40,11 +40,11 @@ static u8 wv_irq_to_psa(int irq)
  */
 static int __init wv_psa_to_irq(u8 irqval)
 {
-	int irq;
+	int i;
 
-	for (irq = 0; irq < ARRAY_SIZE(irqvals); irq++)
-		if (irqvals[irq] == irqval)
-			return irq;
+	for (i = 0; i < ARRAY_SIZE(irqvals); i++)
+		if (irqvals[i] == irqval)
+			return i;
 
 	return -1;
 }

