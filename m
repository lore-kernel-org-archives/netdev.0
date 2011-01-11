From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCH 10/16] drivers/net: stmmac: don't treat NULL clk as an error
Date: Tue, 11 Jan 2011 12:43:47 +0000
Message-ID: <1294749833-32019-11-git-send-email-jamie@jamieiles.com>
References: <1294749833-32019-1-git-send-email-jamie@jamieiles.com>
Cc: Jamie Iles <jamie@jamieiles.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294749833-32019-1-git-send-email-jamie@jamieiles.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

clk_get() returns a struct clk cookie to the driver and some platforms
may return NULL if they only support a single clock.  clk_get() has only
failed if it returns a ERR_PTR() encoded pointer.

Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 drivers/net/stmmac/stmmac_timer.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_timer.c b/drivers/net/stmmac/stmmac_timer.c
index 2a0e1ab..ebb1b37 100644
--- a/drivers/net/stmmac/stmmac_timer.c
+++ b/drivers/net/stmmac/stmmac_timer.c
@@ -91,6 +91,7 @@ int stmmac_close_ext_timer(void)
 
 #elif defined(CONFIG_STMMAC_TMU_TIMER)
 #include <linux/clk.h>
+#include <linux/err.h>
 #define TMU_CHANNEL "tmu2_clk"
 static struct clk *timer_clock;
 
@@ -109,7 +110,7 @@ int stmmac_open_ext_timer(struct net_device *dev, struct stmmac_timer *tm)
 {
 	timer_clock = clk_get(NULL, TMU_CHANNEL);
 
-	if (timer_clock == NULL)
+	if (IS_ERR(timer_clock))
 		return -1;
 
 	if (tmu2_register_user(stmmac_timer_handler, (void *)dev) < 0) {
-- 
1.7.3.4
