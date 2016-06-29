From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] be2net: signedness bug in be_msix_enable()
Date: Wed, 29 Jun 2016 17:39:43 +0300
Message-ID: <20160629143943.GA22818@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
	Somnath Kotur <somnath.kotur@broadcom.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Sathya Perla <sathya.perla@broadcom.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"num_vec" needs to be signed for the error handling to work.

Fixes: e261768e9e39 ('be2net: support asymmetric rx/tx queue counts')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 1873c74..1f16e73 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3251,8 +3251,9 @@ static void be_msix_disable(struct be_adapter *adapter)
 
 static int be_msix_enable(struct be_adapter *adapter)
 {
-	unsigned int i, num_vec, max_roce_eqs;
+	unsigned int i, max_roce_eqs;
 	struct device *dev = &adapter->pdev->dev;
+	int num_vec;
 
 	/* If RoCE is supported, program the max number of vectors that
 	 * could be used for NIC and RoCE, else, just program the number
