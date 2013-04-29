From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 05/21] atm: he: use msleep instead of large udelay constants
Date: Mon, 29 Apr 2013 15:13:26 +0200
Message-ID: <201304291513.27104.arnd@arndb.de>
References: <1366910944-3033663-1-git-send-email-arnd@arndb.de> <AE90C24D6B3A694183C094C60CF0A2F6026B7203@saturn3.aculab.com> <20130426091220.468cf59e@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Laight" <David.Laight@aculab.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130426091220.468cf59e@thirdoffive.cmf.nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From a0ddf082821b064cc2d6a9bb90861f9b81a559a5 Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 14 Mar 2013 15:21:36 +0100
Subject: [PATCH] atm: he: use mdelay instead of large udelay constants

ARM cannot handle udelay for more than 2 miliseconds, and
it is rather bad style to block the cpu for 16ms anyway,
so let's use msleep instead.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: linux-atm-general@lists.sourceforge.net
Cc: netdev@vger.kernel.org
---
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index d689126..507362a 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -1055,7 +1055,7 @@ static int he_start(struct atm_dev *dev)
 	he_writel(he_dev, 0x0, RESET_CNTL);
 	he_writel(he_dev, 0xff, RESET_CNTL);
 
-	udelay(16*1000);	/* 16 ms */
+	msleep(16);	/* 16 ms */
 	status = he_readl(he_dev, RESET_CNTL);
 	if ((status & BOARD_RST_STATUS) == 0) {
 		hprintk("reset failed\n");
