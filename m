From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v3 06/13] net: ethernet: ti: cpts: disable cpts when unregistered
Date: Fri, 2 Dec 2016 14:30:16 -0600
Message-ID: <20161202203023.25526-7-grygorii.strashko@ti.com>
References: <20161202203023.25526-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx193.ext.ti.com ([198.47.27.77]:24998 "EHLO
        lelnx193.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753836AbcLBUar (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 15:30:47 -0500
In-Reply-To: <20161202203023.25526-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The cpts now is left enabled after unregistration.
Hence, disable it in cpts_unregister().

Acked-by: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
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
