From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 9/9] net: ethernet: ti: cpts: switch to readl/writel_relaxed()
Date: Wed, 14 Sep 2016 16:02:31 +0300
Message-ID: <20160914130231.3035-10-grygorii.strashko@ti.com>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160914130231.3035-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switch to readl/writel_relaxed() APIs, because The CPTS IP is reused
on Keystone 2 SoCs where LE/BE modes are supported.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpts.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index cbe0974..0226582 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -31,8 +31,8 @@
 
 #include "cpts.h"
 
-#define cpts_read32(c, r)	__raw_readl(&c->reg->r)
-#define cpts_write32(c, v, r)	__raw_writel(v, &c->reg->r)
+#define cpts_read32(c, r)	readl_relaxed(&c->reg->r)
+#define cpts_write32(c, v, r)	writel_relaxed(v, &c->reg->r)
 
 static int event_expired(struct cpts_event *event)
 {
-- 
2.9.3
