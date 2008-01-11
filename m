From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH 5/5] spidernet: revise link status logging
Date: Fri, 11 Jan 2008 15:48:47 +0900 (JST)
Message-ID: <20080111.154847.-494080281.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:52110 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbYAKG5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 01:57:03 -0500
Received: from imx12.toshiba.co.jp (imx12 [61.202.160.132])
	by imx9.toshiba.co.jp  with ESMTP id m0B6v2F7001885
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 15:57:02 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch revises the logging for link informations of spidernet.

  - The link down message is too verbose because auto-negotiation timeout
    occurs periodically while an ethernet cable is not connected. 
  - We want to see the link result, and we think it should be displayed. 

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
---

Index: linux-powerpc-git/drivers/net/spider_net.c
===================================================================
--- linux-powerpc-git.orig/drivers/net/spider_net.c
+++ linux-powerpc-git/drivers/net/spider_net.c
@@ -2045,7 +2045,8 @@ static void spider_net_link_phy(unsigned
 	/* if link didn't come up after SPIDER_NET_ANEG_TIMEOUT tries, setup phy again */
 	if (card->aneg_count > SPIDER_NET_ANEG_TIMEOUT) {
 
-		pr_info("%s: link is down trying to bring it up\n", card->netdev->name);
+		pr_debug("%s: link is down trying to bring it up\n",
+			 card->netdev->name);
 
 		switch (card->medium) {
 		case BCM54XX_COPPER:
@@ -2096,9 +2097,10 @@ static void spider_net_link_phy(unsigned
 
 	card->aneg_count = 0;
 
-	pr_debug("Found %s with %i Mbps, %s-duplex %sautoneg.\n",
-		phy->def->name, phy->speed, phy->duplex==1 ? "Full" : "Half",
-		phy->autoneg==1 ? "" : "no ");
+	pr_info("%s: link up, %i Mbps, %s-duplex %sautoneg.\n",
+		card->netdev->name, phy->speed,
+		phy->duplex == 1 ? "Full" : "Half",
+		phy->autoneg == 1 ? "" : "no ");
 
 	return;
 }
