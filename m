From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/6] cnic: Reset tcp_flags during cnic_cm_create().
Date: Sun, 28 Jul 2013 19:03:57 -0700
Message-ID: <1375063440-4016-3-git-send-email-mchan@broadcom.com>
References: <1375063440-4016-1-git-send-email-mchan@broadcom.com>
 <1375063440-4016-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4305 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752062Ab3G2BmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jul 2013 21:42:13 -0400
In-Reply-To: <1375063440-4016-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eddie Wai <eddie.wai@broadcom.com>

Without resetting it, the bnx2i driver cannot use different options for
different iSCSI connections.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index c6822e1..1a2e5ff 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -3603,6 +3603,7 @@ static int cnic_cm_create(struct cnic_dev *dev, int ulp_type, u32 cid,
 	csk1->rcv_buf = DEF_RCV_BUF;
 	csk1->snd_buf = DEF_SND_BUF;
 	csk1->seed = DEF_SEED;
+	csk1->tcp_flags = 0;
 
 	*csk = csk1;
 	return 0;
-- 
1.7.1
