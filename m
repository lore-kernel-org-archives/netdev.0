From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/2 net-next] cnic: set error flag when iSCSI connection
 fails
Date: Wed, 8 Feb 2012 19:33:56 -0800
Message-ID: <1328758437-18306-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1815 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757792Ab2BID0n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Feb 2012 22:26:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeffrey Huang <huangjw@broadcom.com>

to speed up error recovery due to SPQ failures.  The error flag will
expedite the recovery process by skipping the timeouts.

Signed-off-by: Jeffrey Huang <huangjw@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 7381460..e236560 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -3927,6 +3927,8 @@ static void cnic_cm_process_kcqe(struct cnic_dev *dev, struct kcqe *kcqe)
 	case L4_KCQE_OPCODE_VALUE_CONNECT_COMPLETE:
 		if (l4kcqe->status == 0)
 			set_bit(SK_F_OFFLD_COMPLETE, &csk->flags);
+		else if (l4kcqe->status == L4_KCQE_COMPLETION_STATUS_NIC_ERROR)
+			set_bit(SK_F_HW_ERR, &csk->flags);
 
 		smp_mb__before_clear_bit();
 		clear_bit(SK_F_OFFLD_SCHED, &csk->flags);
-- 
1.6.4.GIT
