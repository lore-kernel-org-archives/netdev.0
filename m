From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v5 06/13] net: ethernet: ti: cpts: disable cpts when unregistered
Date: Tue, 6 Dec 2016 18:00:38 -0600
Message-ID: <20161207000045.28333-7-grygorii.strashko@ti.com>
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

The cpts now is left enabled after unregistration.
Hence, disable it in cpts_unregister().

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpts.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 3dda6d5..d3c1ac5 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -404,6 +404,10 @@ void cpts_unregister(struct cpts *cpts)
 		ptp_clock_unregister(cpts->clock);
 		cancel_delayed_work_sync(&cpts->overflow_work);
 	}
+
+	cpts_write32(cpts, 0, int_enable);
+	cpts_write32(cpts, 0, control);
+
 	if (cpts->refclk)
 		cpts_clk_release(cpts);
 }
-- 
2.10.1
