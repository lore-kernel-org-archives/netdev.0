From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v5 01/13] net: ethernet: ti: cpts: switch to readl/writel_relaxed()
Date: Tue, 6 Dec 2016 18:00:33 -0600
Message-ID: <20161207000045.28333-2-grygorii.strashko@ti.com>
References: <20161207000045.28333-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161207000045.28333-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switch to readl/writel_relaxed() APIs, because this is recommended
API and the CPTS IP is reused on Keystone 2 SoCs
where LE/BE modes are supported.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpts.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 85a55b4..a42c449 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -33,8 +33,8 @@
 
 #ifdef CONFIG_TI_CPTS
 
-#define cpts_read32(c, r)	__raw_readl(&c->reg->r)
-#define cpts_write32(c, v, r)	__raw_writel(v, &c->reg->r)
+#define cpts_read32(c, r)	readl_relaxed(&c->reg->r)
+#define cpts_write32(c, v, r)	writel_relaxed(v, &c->reg->r)
 
 static int event_expired(struct cpts_event *event)
 {
-- 
2.10.1
