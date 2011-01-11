From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCH 11/16] drivers/net: sh_irda: don't treat NULL clk as an error
Date: Tue, 11 Jan 2011 12:43:48 +0000
Message-ID: <1294749833-32019-12-git-send-email-jamie@jamieiles.com>
References: <1294749833-32019-1-git-send-email-jamie@jamieiles.com>
Cc: Jamie Iles <jamie@jamieiles.com>, Samuel Ortiz <samuel@sortiz.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294749833-32019-1-git-send-email-jamie@jamieiles.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

clk_get() returns a struct clk cookie to the driver and some platforms
may return NULL if they only support a single clock.  clk_get() has only
failed if it returns a ERR_PTR() encoded pointer.

Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 drivers/net/irda/sh_sir.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/irda/sh_sir.c b/drivers/net/irda/sh_sir.c
index 52a7c86..56ba91a 100644
--- a/drivers/net/irda/sh_sir.c
+++ b/drivers/net/irda/sh_sir.c
@@ -12,6 +12,7 @@
  * published by the Free Software Foundation.
  */
 
+#include <linux/err.h>
 #include <linux/module.h>
 #include <linux/platform_device.h>
 #include <linux/slab.h>
@@ -278,9 +279,9 @@ static int sh_sir_set_baudrate(struct sh_sir_self *self, u32 baudrate)
 	}
 
 	clk = clk_get(NULL, "irda_clk");
-	if (!clk) {
+	if (IS_ERR(clk)) {
 		dev_err(dev, "can not get irda_clk\n");
-		return -EIO;
+		return PTR_ERR(clk);
 	}
 
 	clk_set_rate(clk, sh_sir_find_sclk(clk));
-- 
1.7.3.4
