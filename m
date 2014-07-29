From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next] dcbnl : Fix misleading dcb_app->priority explanation
Date: Mon, 28 Jul 2014 20:57:07 -0700
Message-ID: <1406606227-22776-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, john.fastabend@gmail.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:46422
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752223AbaG2D5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 23:57:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current explanation of dcb_app->priority is wrong. It says priority is
expected to be a 3-bit unsigned integer which is only true when working with
DCBx-IEEE. Use of dcb_app->priority by DCBx-CEE expects it to be 802.1p user
priority bitmap. Updated accordingly

This affects the cxgb4 driver, but I will post those changes as part of a
larger changeset shortly.

Fixes: 3e29027af4372 ("dcbnl: add support for ieee8021Qaz attributes")
Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 include/uapi/linux/dcbnl.h | 3 ++-
 net/dcb/dcbnl.c            | 5 +++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/dcbnl.h b/include/uapi/linux/dcbnl.h
index 6bb43382f3f3..e711f20dc522 100644
--- a/include/uapi/linux/dcbnl.h
+++ b/include/uapi/linux/dcbnl.h
@@ -148,7 +148,8 @@ struct cee_pfc {
  *
  * @selector: protocol identifier type
  * @protocol: protocol of type indicated
- * @priority: 3-bit unsigned integer indicating priority
+ * @priority: 3-bit unsigned integer indicating priority for IEEE
+ *            8-bit 802.1p user priority bitmap for CEE
  *
  * ----
  *  Selector field values
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index c34af7a1d2d4..ca11d283bbeb 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1776,7 +1776,7 @@ EXPORT_SYMBOL(dcb_getapp);
  *
  * Priority 0 is an invalid priority in CEE spec. This routine
  * removes applications from the app list if the priority is
- * set to zero.
+ * set to zero. Priority is expected to be 8-bit 802.1p user priority bitmap
  */
 int dcb_setapp(struct net_device *dev, struct dcb_app *new)
 {
@@ -1837,7 +1837,8 @@ EXPORT_SYMBOL(dcb_ieee_getapp_mask);
  *
  * This adds Application data to the list. Multiple application
  * entries may exists for the same selector and protocol as long
- * as the priorities are different.
+ * as the priorities are different. Priority is expected to be a
+ * 3-bit unsigned integer
  */
 int dcb_ieee_setapp(struct net_device *dev, struct dcb_app *new)
 {
-- 
2.0.3
