From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/9] drivers/isdn/mISDN: Use printf extension %pV
Date: Tue,  9 Nov 2010 16:35:16 -0800
Message-ID: <b7079ecc43454c8b8baaef07f8cf1c1756c2ce3e.1289348757.git.joe@perches.com>
References: <cover.1289348757.git.joe@perches.com>
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1289348757.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using %pV reduces the number of printk calls and
eliminates any possible message interleaving from
other printk calls.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/isdn/mISDN/layer1.c |   10 +++++++---
 drivers/isdn/mISDN/layer2.c |   12 +++++++++---
 drivers/isdn/mISDN/tei.c    |   23 +++++++++++++++++------
 3 files changed, 33 insertions(+), 12 deletions(-)

diff --git a/drivers/isdn/mISDN/layer1.c b/drivers/isdn/mISDN/layer1.c
index ac4aa18..5cc7c00 100644
--- a/drivers/isdn/mISDN/layer1.c
+++ b/drivers/isdn/mISDN/layer1.c
@@ -99,12 +99,16 @@ static void
 l1m_debug(struct FsmInst *fi, char *fmt, ...)
 {
 	struct layer1 *l1 = fi->userdata;
+	struct va_format vaf;
 	va_list va;
 
 	va_start(va, fmt);
-	printk(KERN_DEBUG "%s: ", dev_name(&l1->dch->dev.dev));
-	vprintk(fmt, va);
-	printk("\n");
+
+	vaf.fmt = fmt;
+	vaf.va = &va;
+
+	printk(KERN_DEBUG "%s: %pV\n", dev_name(&l1->dch->dev.dev), &vaf);
+
 	va_end(va);
 }
 
diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
index c973717..4ae7505 100644
--- a/drivers/isdn/mISDN/layer2.c
+++ b/drivers/isdn/mISDN/layer2.c
@@ -95,14 +95,20 @@ static void
 l2m_debug(struct FsmInst *fi, char *fmt, ...)
 {
 	struct layer2 *l2 = fi->userdata;
+	struct va_format vaf;
 	va_list va;
 
 	if (!(*debug & DEBUG_L2_FSM))
 		return;
+
 	va_start(va, fmt);
-	printk(KERN_DEBUG "l2 (sapi %d tei %d): ", l2->sapi, l2->tei);
-	vprintk(fmt, va);
-	printk("\n");
+
+	vaf.fmt = fmt;
+	vaf.va = &va;
+
+	printk(KERN_DEBUG "l2 (sapi %d tei %d): %pV\n",
+	       l2->sapi, l2->tei, &vaf);
+
 	va_end(va);
 }
 
diff --git a/drivers/isdn/mISDN/tei.c b/drivers/isdn/mISDN/tei.c
index 1b85d9d..687c9b6 100644
--- a/drivers/isdn/mISDN/tei.c
+++ b/drivers/isdn/mISDN/tei.c
@@ -79,14 +79,19 @@ static void
 da_debug(struct FsmInst *fi, char *fmt, ...)
 {
 	struct manager	*mgr = fi->userdata;
+	struct va_format vaf;
 	va_list va;
 
 	if (!(*debug & DEBUG_L2_TEIFSM))
 		return;
+
 	va_start(va, fmt);
-	printk(KERN_DEBUG "mgr(%d): ", mgr->ch.st->dev->id);
-	vprintk(fmt, va);
-	printk("\n");
+
+	vaf.fmt = fmt;
+	vaf.va = &va;
+
+	printk(KERN_DEBUG "mgr(%d): %pV\n", mgr->ch.st->dev->id, &vaf);
+
 	va_end(va);
 }
 
@@ -223,14 +228,20 @@ static void
 tei_debug(struct FsmInst *fi, char *fmt, ...)
 {
 	struct teimgr	*tm = fi->userdata;
+	struct va_format vaf;
 	va_list va;
 
 	if (!(*debug & DEBUG_L2_TEIFSM))
 		return;
+
 	va_start(va, fmt);
-	printk(KERN_DEBUG "sapi(%d) tei(%d): ", tm->l2->sapi, tm->l2->tei);
-	vprintk(fmt, va);
-	printk("\n");
+
+	vaf.fmt = fmt;
+	vaf.va = &va;
+
+	printk(KERN_DEBUG "sapi(%d) tei(%d): %pV\n",
+	       tm->l2->sapi, tm->l2->tei, &vaf);
+
 	va_end(va);
 }
 
-- 
1.7.3.1.g432b3.dirty
