From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH 1/2] orinoco: Don't use "extern inline" on locking functions
Date: Tue, 15 Aug 2006 20:45:00 -0400
Message-ID: <20060816004500.3035.77174.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-64-105-159-118.phlapafg.covad.net ([64.105.159.118]:19174
	"EHLO smtp.roinet.com") by vger.kernel.org with ESMTP
	id S1750736AbWHPApC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 20:45:02 -0400
Received: from dv.roinet.com (192.168.1.21 [192.168.1.21])
    by smtp.roinet.com with SMTP;
    for netdev@vger.kernel.org;
    Tue, 15 Aug 2006 20:49:15 -0400 (EDT)
    (envelope-from proski@gnu.org)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski@gnu.org>

SPARC architecture has been fixed, so it's no longer needed.

Signed-off-by: Pavel Roskin <proski@gnu.org>
---

 drivers/net/wireless/orinoco.h |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/orinoco.h b/drivers/net/wireless/orinoco.h
index 16db3e1..fb5700d 100644
--- a/drivers/net/wireless/orinoco.h
+++ b/drivers/net/wireless/orinoco.h
@@ -134,11 +134,7 @@ extern irqreturn_t orinoco_interrupt(int
 /* Locking and synchronization functions                            */
 /********************************************************************/
 
-/* These functions *must* be inline or they will break horribly on
- * SPARC, due to its weird semantics for save/restore flags. extern
- * inline should prevent the kernel from linking or module from
- * loading if they are not inlined. */
-extern inline int orinoco_lock(struct orinoco_private *priv,
+static inline int orinoco_lock(struct orinoco_private *priv,
 			       unsigned long *flags)
 {
 	spin_lock_irqsave(&priv->lock, *flags);
@@ -151,7 +147,7 @@ extern inline int orinoco_lock(struct or
 	return 0;
 }
 
-extern inline void orinoco_unlock(struct orinoco_private *priv,
+static inline void orinoco_unlock(struct orinoco_private *priv,
 				  unsigned long *flags)
 {
 	spin_unlock_irqrestore(&priv->lock, *flags);
