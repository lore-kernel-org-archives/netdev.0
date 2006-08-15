From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH] Use __always_inline in orinoco_lock()/orinoco_unlock()
Date: Tue, 15 Aug 2006 15:25:58 -0400
Message-ID: <20060815192558.3590.63591.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-64-105-159-118.phlapafg.covad.net ([64.105.159.118]:37019
	"EHLO smtp.roinet.com") by vger.kernel.org with ESMTP
	id S965126AbWHOT0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 15:26:00 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski@gnu.org>

This is exactly the case when they are needed.  This also fixed a
warning with -Wmissing-prototypes

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Pavel Roskin <proski@gnu.org>
---

 drivers/net/wireless/orinoco.h |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/orinoco.h b/drivers/net/wireless/orinoco.h
index 16db3e1..8fd9b32 100644
--- a/drivers/net/wireless/orinoco.h
+++ b/drivers/net/wireless/orinoco.h
@@ -135,11 +135,9 @@ extern irqreturn_t orinoco_interrupt(int
 /********************************************************************/
 
 /* These functions *must* be inline or they will break horribly on
- * SPARC, due to its weird semantics for save/restore flags. extern
- * inline should prevent the kernel from linking or module from
- * loading if they are not inlined. */
-extern inline int orinoco_lock(struct orinoco_private *priv,
-			       unsigned long *flags)
+ * SPARC, due to its weird semantics for save/restore flags. */
+static __always_inline int orinoco_lock(struct orinoco_private *priv,
+					unsigned long *flags)
 {
 	spin_lock_irqsave(&priv->lock, *flags);
 	if (priv->hw_unavailable) {
@@ -151,8 +149,8 @@ extern inline int orinoco_lock(struct or
 	return 0;
 }
 
-extern inline void orinoco_unlock(struct orinoco_private *priv,
-				  unsigned long *flags)
+static __always_inline void orinoco_unlock(struct orinoco_private *priv,
+					   unsigned long *flags)
 {
 	spin_unlock_irqrestore(&priv->lock, *flags);
 }
