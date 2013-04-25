From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 05/21] atm: he: use mdelay instead of large udelay constants
Date: Thu, 25 Apr 2013 19:28:48 +0200
Message-ID: <1366910944-3033663-6-git-send-email-arnd@arndb.de>
References: <1366910944-3033663-1-git-send-email-arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366910944-3033663-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ARM cannot handle udelay for more than 2 miliseconds, so we
should use mdelay instead for those.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: linux-atm-general@lists.sourceforge.net
Cc: netdev@vger.kernel.org
---
 drivers/atm/he.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index d689126..7700061 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -1055,7 +1055,7 @@ static int he_start(struct atm_dev *dev)
 	he_writel(he_dev, 0x0, RESET_CNTL);
 	he_writel(he_dev, 0xff, RESET_CNTL);
 
-	udelay(16*1000);	/* 16 ms */
+	mdelay(16);	/* 16 ms */
 	status = he_readl(he_dev, RESET_CNTL);
 	if ((status & BOARD_RST_STATUS) == 0) {
 		hprintk("reset failed\n");
-- 
1.8.1.2
