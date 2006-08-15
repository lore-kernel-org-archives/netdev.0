From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] orinoco.h: "extern inline" -> "static __always_inline"
Date: Tue, 15 Aug 2006 02:40:46 +0200
Message-ID: <20060815004046.GC3543@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: orinoco-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linville@tuxdriver.com, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:56583 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S932763AbWHOAks (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 20:40:48 -0400
To: proski@gnu.org, hermes@gibson.dropbear.id.au
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"extern inline" generates a warning with -Wmissing-prototypes and I'm 
currently working on getting the kernel cleaned up for adding this to 
the CFLAGS since it will help us to avoid a nasty class of runtime 
errors.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/net/wireless/orinoco.h |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

--- linux-2.6.18-rc4-mm1/drivers/net/wireless/orinoco.h.old	2006-08-13 23:14:05.000000000 +0200
+++ linux-2.6.18-rc4-mm1/drivers/net/wireless/orinoco.h	2006-08-13 23:14:39.000000000 +0200
@@ -138,8 +138,8 @@
  * SPARC, due to its weird semantics for save/restore flags. extern
  * inline should prevent the kernel from linking or module from
  * loading if they are not inlined. */
-extern inline int orinoco_lock(struct orinoco_private *priv,
-			       unsigned long *flags)
+static __always_inline int orinoco_lock(struct orinoco_private *priv,
+					unsigned long *flags)
 {
 	spin_lock_irqsave(&priv->lock, *flags);
 	if (priv->hw_unavailable) {
@@ -151,8 +151,8 @@
 	return 0;
 }
 
-extern inline void orinoco_unlock(struct orinoco_private *priv,
-				  unsigned long *flags)
+static __always_inline void orinoco_unlock(struct orinoco_private *priv,
+					   unsigned long *flags)
 {
 	spin_unlock_irqrestore(&priv->lock, *flags);
 }

