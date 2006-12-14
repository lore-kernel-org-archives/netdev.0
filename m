From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/3][BNX2]: Fix bug in bnx2_nvram_write().
Date: Wed, 13 Dec 2006 18:30:39 -0800
Message-ID: <1166063439.30522.6.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4035 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944AbWLNBsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 20:48:05 -0500
To: davem@davemloft.net, agospoda@redhat.com, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix bug in bnx2_nvram_write().

Length was not calculated correctly if the NVRAM offset is on a non-
aligned offset.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index f296c37..4fa7cef 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3096,7 +3096,7 @@ bnx2_nvram_write(struct bnx2 *bp, u32 of
 
 	if ((align_start = (offset32 & 3))) {
 		offset32 &= ~3;
-		len32 += align_start;
+		len32 += (4 - align_start);
 		if ((rc = bnx2_nvram_read(bp, offset32, start, 4)))
 			return rc;
 	}
@@ -3114,7 +3114,7 @@ bnx2_nvram_write(struct bnx2 *bp, u32 of
 
 	if (align_start || align_end) {
 		buf = kmalloc(len32, GFP_KERNEL);
-		if (buf == 0)
+		if (buf == NULL)
 			return -ENOMEM;
 		if (align_start) {
 			memcpy(buf, start, 4);


