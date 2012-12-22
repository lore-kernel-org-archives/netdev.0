From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 2/2] cpts: fix a run time warn_on.
Date: Sat, 22 Dec 2012 20:41:09 +0100
Message-ID: <ad26ca328f0eba6a722d0288ac1c37ad55789447.1356204860.git.richardcochran@gmail.com>
References: <cover.1356204860.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f44.google.com ([209.85.214.44]:48083 "EHLO
	mail-bk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164Ab2LVTla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2012 14:41:30 -0500
In-Reply-To: <cover.1356204860.git.richardcochran@gmail.com>
In-Reply-To: <cover.1356204860.git.richardcochran@gmail.com>
References: <cover.1356204860.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a warning in clk_enable by calling clk_prepare first.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpts.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 5ab8fb4..3e32a31 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -247,6 +247,7 @@ static void cpts_clk_init(struct cpts *cpts)
 		cpts->refclk = NULL;
 		return;
 	}
+	clk_prepare(cpts->refclk);
 	clk_enable(cpts->refclk);
 }
 
-- 
1.7.2.5
