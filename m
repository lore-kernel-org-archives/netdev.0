From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 08/10] liquidio: Droq validation
Date: Sun, 3 Jul 2016 13:56:54 -0700
Message-ID: <1467579416-24219-9-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1467579416-24219-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0079.outbound.protection.outlook.com ([104.47.32.79]:42816
	"EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932236AbcGCVam (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jul 2016 17:30:42 -0400
In-Reply-To: <1467579416-24219-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes redudant droq num validation.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 8bfbe8c..93ab4ec 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -821,18 +821,6 @@ octeon_process_droq_poll_cmd(struct octeon_device *oct, u32 q_no, int cmd,
 			     u32 arg)
 {
 	struct octeon_droq *droq;
-	struct octeon_config *oct_cfg = NULL;
-
-	oct_cfg = octeon_get_conf(oct);
-
-	if (!oct_cfg)
-		return -EINVAL;
-
-	if (q_no >= CFG_GET_OQ_MAX_Q(oct_cfg)) {
-		dev_err(&oct->pci_dev->dev, "%s: droq id (%d) exceeds MAX (%d)\n",
-			__func__, q_no, (oct->num_oqs - 1));
-		return -EINVAL;
-	}
 
 	droq = oct->droq[q_no];
 
-- 
1.8.3.1
