From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 4/9] qlcnic: fix beaconing test for 82xx adapter
Date: Sat, 13 Apr 2013 13:28:29 -0400
Message-ID: <1365874114-6759-5-git-send-email-shahed.shaikh@qlogic.com>
References: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:47472 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751438Ab3DMRwh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Apr 2013 13:52:37 -0400
In-Reply-To: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o Commit 319ecf121e1da3d75dd1bde32fed255532e61797
  ("qlcnic: 83xx sysfs routines") introduced regression
  for beaconing test while refactoring 82xx code. This patch is to
  revert code to fix beaconing test for 82xx adapter.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index a17671d..6f74dc8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -207,10 +207,10 @@ beacon_err:
 	}
 
 	err = qlcnic_config_led(adapter, b_state, b_rate);
-	if (!err)
+	if (!err) {
 		err = len;
-	else
 		ahw->beacon_state = b_state;
+	}
 
 	if (test_and_clear_bit(__QLCNIC_DIAG_RES_ALLOC, &adapter->state))
 		qlcnic_diag_free_res(adapter->netdev, max_sds_rings);
-- 
1.5.6
