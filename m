From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/8 net-next] cnic: Convert ctx_flags to bit fields
Date: Wed, 13 Oct 2010 17:06:45 -0700
Message-ID: <1287014811-10979-3-git-send-email-mchan@broadcom.com>
References: <1287014811-10979-1-git-send-email-mchan@broadcom.com>
 <1287014811-10979-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3291 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753068Ab0JNBEB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 21:04:01 -0400
In-Reply-To: <1287014811-10979-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

so that we can additional bit definitions without requiring a spinlock.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |    4 ++--
 drivers/net/cnic.h |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 0fab720..311b2e6 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -1721,7 +1721,7 @@ static int cnic_bnx2x_iscsi_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
 	struct kcqe *cqes[1];
 	u32 hw_cid, type;
 
-	if (!(ctx->ctx_flags & CTX_FL_OFFLD_START))
+	if (!test_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags))
 		goto skip_cfc_delete;
 
 	while (!time_after(jiffies, ctx->timestamp + (2 * HZ)))
@@ -1943,7 +1943,7 @@ static int cnic_bnx2x_connect(struct cnic_dev *dev, struct kwqe *wqes[],
 	ret = cnic_submit_kwqe_16(dev, L5CM_RAMROD_CMD_ID_TCP_CONNECT,
 			kwqe1->cid, ISCSI_CONNECTION_TYPE, &l5_data);
 	if (!ret)
-		ctx->ctx_flags |= CTX_FL_OFFLD_START;
+		set_bit(CTX_FL_OFFLD_START, &ctx->ctx_flags);
 
 	return ret;
 }
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index 676d008..9907cc2 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -168,8 +168,8 @@ struct cnic_context {
 	wait_queue_head_t	waitq;
 	int			wait_cond;
 	unsigned long		timestamp;
-	u32			ctx_flags;
-#define	CTX_FL_OFFLD_START	0x00000001
+	unsigned long		ctx_flags;
+#define	CTX_FL_OFFLD_START	0
 	u8			ulp_proto_id;
 	union {
 		struct cnic_iscsi	*iscsi;
-- 
1.6.4.GIT


