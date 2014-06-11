From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] drivers: net: davinci_cpdma: double free on error
Date: Wed, 11 Jun 2014 11:16:51 +0300
Message-ID: <20140611081651.GB29572@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olof Johansson <olof@lixom.net>,
	George Cherian <george.cherian@ti.com>,
	Christian Riesch <christian.riesch@omicron.at>,
	Daniel Mack <zonque@gmail.com>,
	Sebastian Siewior <bigeasy@linutronix.de>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We recently change the kzalloc() to devm_kzalloc() so freeing "ctlr"
here could lead to a double free.

Fixes: e194312854ed ('drivers: net: davinci_cpdma: Convert kzalloc() to devm_kzalloc().')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 539dbde..4a000f6 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -285,10 +285,8 @@ struct cpdma_ctlr *cpdma_ctlr_create(struct cpdma_params *params)
 					    ctlr->params.desc_hw_addr,
 					    ctlr->params.desc_mem_size,
 					    ctlr->params.desc_align);
-	if (!ctlr->pool) {
-		kfree(ctlr);
+	if (!ctlr->pool)
 		return NULL;
-	}
 
 	if (WARN_ON(ctlr->num_chan > CPDMA_MAX_CHANNELS))
 		ctlr->num_chan = CPDMA_MAX_CHANNELS;
