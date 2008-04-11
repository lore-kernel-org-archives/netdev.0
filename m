From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH 1/5] spidernet: add missing initialization
Date: Fri, 11 Apr 2008 12:27:34 +0900 (JST)
Message-ID: <20080411.122734.-1300523219.kouish@swc.toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jens@de.ibm.com, netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:49147 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbYDKDeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 23:34:01 -0400
Received: from imx12.toshiba.co.jp (imx12 [61.202.160.132])
	by imx9.toshiba.co.jp  with ESMTP id m3B3Xxvr020997
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 12:33:59 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes initialization of "aneg_count" and "medium" fields in
spider_net_card to make spidernet driver correctly sets "link status".

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
Acked-by: Jens Osterkamp <jens@de.ibm.com>
---

Jeff-san,

Could you consider these spidernet patches for 2.6.26?

Best regards,
Kou Ishizaki


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
