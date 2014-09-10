From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/5] cxgb4: Fix t4_flash_erase_sectors() to throw an error when requested to erase sectors which aren't in the FLASH
Date: Wed, 10 Sep 2014 17:44:29 +0530
Message-ID: <1410351271-26428-4-git-send-email-hariprasad@chelsio.com>
References: <1410351271-26428-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:42776
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751344AbaIJMJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 08:09:05 -0400
In-Reply-To: <1410351271-26428-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 7d4cc28..586a5f1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1099,6 +1099,9 @@ static int t4_flash_erase_sectors(struct adapter *adapter, int start, int end)
 {
 	int ret = 0;
 
+	if (end >= adapter->params.sf_nsec)
+		return -EINVAL;
+
 	while (start <= end) {
 		if ((ret = sf1_write(adapter, 1, 0, 1, SF_WR_ENABLE)) != 0 ||
 		    (ret = sf1_write(adapter, 4, 0, 1,
-- 
1.7.1
