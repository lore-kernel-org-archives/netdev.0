From: Cyril Roelandt <tipecaml@gmail.com>
Subject: [PATCH 4/5] net: sfc: fix return value check in efx_ptp_probe_channel().
Date: Wed, 12 Dec 2012 01:24:53 +0100
Message-ID: <1355271894-5284-5-git-send-email-tipecaml@gmail.com>
References: <1355271894-5284-1-git-send-email-tipecaml@gmail.com>
Cc: kernel-janitors@vger.kernel.org,
	Cyril Roelandt <tipecaml@gmail.com>,
	linux-net-drivers@solarflare.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1355271894-5284-1-git-send-email-tipecaml@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ptp_clock_register() returns ERR_PTR() and never returns NULL. Replace the
NULL check by a call to IS_ERR().

Signed-off-by: Cyril Roelandt <tipecaml@gmail.com>
---
 drivers/net/ethernet/sfc/ptp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 0767043f..9bcc38c 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -930,7 +930,7 @@ static int efx_ptp_probe_channel(struct efx_channel *channel)
 
 	ptp->phc_clock = ptp_clock_register(&ptp->phc_clock_info,
 					    &efx->pci_dev->dev);
-	if (!ptp->phc_clock)
+	if (IS_ERR(ptp->phc_clock))
 		goto fail3;
 
 	INIT_WORK(&ptp->pps_work, efx_ptp_pps_worker);
-- 
1.7.10.4
