From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 1/1] qlcnic: fix beaconing test for 82xx adapter
Date: Wed, 17 Apr 2013 00:11:10 -0400
Message-ID: <1366171870-15793-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:21554 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754187Ab3DQEfB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 00:35:01 -0400
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
index 987fb6f..5ef328a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -200,10 +200,10 @@ beacon_err:
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
