From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 1/2] qed: Fix static checker warnings.
Date: Tue, 28 Jun 2016 02:10:58 -0400
Message-ID: <1467094259-16061-2-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1467094259-16061-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:48311 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751331AbcF1Gza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 02:55:30 -0400
In-Reply-To: <1467094259-16061-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Static checker warnings:
drivers/net/ethernet/qlogic/qed/qed_int.c:2450 qed_init_cau_sb_entry()
warn: always true condition '(cdev->rx_coalesce_usecs <= 255) =>
(0-255 <= 255)'
drivers/net/ethernet/qlogic/qed/qed_int.c:2511 qed_int_cau_conf_sb()
warn: always true condition '(p_hwfn->cdev->rx_coalesce_usecs <= 255)
=> (0-255 <= 255)'
..

The data types for rx/tx_coalesce_usecs should be u16.

Fixes: commit 722003ac40c2 ("qed: Add support for coalescing config read/update.")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 9a63df1..35e5377 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -489,8 +489,8 @@ struct qed_dev {
 
 	u32				int_mode;
 	enum qed_coalescing_mode	int_coalescing_mode;
-	u8				rx_coalesce_usecs;
-	u8				tx_coalesce_usecs;
+	u16				rx_coalesce_usecs;
+	u16				tx_coalesce_usecs;
 
 	/* Start Bar offset of first hwfn */
 	void __iomem			*regview;
-- 
1.8.3.1
