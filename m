From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH 1/5] spidernet: add missing initialization
Date: Fri, 11 Jan 2008 15:38:59 +0900 (JST)
Message-ID: <20080111.153859.-1300526764.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-tsb5.toshiba.co.jp ([202.33.96.24]:42689 "EHLO
	inet-tsb5.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbYAKG5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 01:57:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes initialization of "aneg_count" and "medium" fields in
spider_net_card to make spidernet driver correctly sets "link status".

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
---

Index: linux-powerpc-git/drivers/net/spider_net.c
===================================================================
--- linux-powerpc-git.orig/drivers/net/spider_net.c
+++ linux-powerpc-git/drivers/net/spider_net.c
@@ -1399,6 +1399,8 @@ spider_net_link_reset(struct net_device 
 	spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0);
 
 	/* reset phy and setup aneg */
+	card->aneg_count = 0;
+	card->medium = BCM54XX_COPPER;
 	spider_net_setup_aneg(card);
 	mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
 
@@ -1982,6 +1984,8 @@ spider_net_open(struct net_device *netde
 		goto init_firmware_failed;
 
 	/* start probing with copper */
+	card->aneg_count = 0;
+	card->medium = BCM54XX_COPPER;
 	spider_net_setup_aneg(card);
 	if (card->phy.def->phy_id)
 		mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
