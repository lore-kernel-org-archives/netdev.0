From: Joe Perches <joe@perches.com>
Subject: [TRIVIAL PATCH next 06/15] isdn: Convert vmalloc/memset to vzalloc
Date: Sat, 28 May 2011 10:36:26 -0700
Message-ID: <db81a56e3fe6a88a4b2d558f8f68405742d26d65.1306603968.git.joe@perches.com>
References: <cover.1306603968.git.joe@perches.com>
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2207 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755262Ab1E1RhF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 May 2011 13:37:05 -0400
In-Reply-To: <cover.1306603968.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/isdn/i4l/isdn_common.c   |    4 ++--
 drivers/isdn/mISDN/dsp_core.c    |    3 +--
 drivers/isdn/mISDN/l1oip_codec.c |    6 ++----
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_common.c b/drivers/isdn/i4l/isdn_common.c
index 6ed82ad..6ddb795e 100644
--- a/drivers/isdn/i4l/isdn_common.c
+++ b/drivers/isdn/i4l/isdn_common.c
@@ -2308,11 +2308,11 @@ static int __init isdn_init(void)
 	int i;
 	char tmprev[50];
 
-	if (!(dev = vmalloc(sizeof(isdn_dev)))) {
+	dev = vzalloc(sizeof(isdn_dev));
+	if (!dev) {
 		printk(KERN_WARNING "isdn: Could not allocate device-struct.\n");
 		return -EIO;
 	}
-	memset((char *) dev, 0, sizeof(isdn_dev));
 	init_timer(&dev->timer);
 	dev->timer.function = isdn_timer_funct;
 	spin_lock_init(&dev->lock);
diff --git a/drivers/isdn/mISDN/dsp_core.c b/drivers/isdn/mISDN/dsp_core.c
index 2877291..0c41553 100644
--- a/drivers/isdn/mISDN/dsp_core.c
+++ b/drivers/isdn/mISDN/dsp_core.c
@@ -1052,12 +1052,11 @@ dspcreate(struct channel_req *crq)
 	if (crq->protocol != ISDN_P_B_L2DSP
 	 && crq->protocol != ISDN_P_B_L2DSPHDLC)
 		return -EPROTONOSUPPORT;
-	ndsp = vmalloc(sizeof(struct dsp));
+	ndsp = vzalloc(sizeof(struct dsp));
 	if (!ndsp) {
 		printk(KERN_ERR "%s: vmalloc struct dsp failed\n", __func__);
 		return -ENOMEM;
 	}
-	memset(ndsp, 0, sizeof(struct dsp));
 	if (dsp_debug & DEBUG_DSP_CTRL)
 		printk(KERN_DEBUG "%s: creating new dsp instance\n", __func__);
 
diff --git a/drivers/isdn/mISDN/l1oip_codec.c b/drivers/isdn/mISDN/l1oip_codec.c
index bbfd1b8..5a89972 100644
--- a/drivers/isdn/mISDN/l1oip_codec.c
+++ b/drivers/isdn/mISDN/l1oip_codec.c
@@ -330,14 +330,12 @@ l1oip_4bit_alloc(int ulaw)
 		return 0;
 
 	/* alloc conversion tables */
-	table_com = vmalloc(65536);
-	table_dec = vmalloc(512);
+	table_com = vzalloc(65536);
+	table_dec = vzalloc(512);
 	if (!table_com || !table_dec) {
 		l1oip_4bit_free();
 		return -ENOMEM;
 	}
-	memset(table_com, 0, 65536);
-	memset(table_dec, 0, 512);
 	/* generate compression table */
 	i1 = 0;
 	while (i1 < 256) {
-- 
1.7.5.rc3.dirty

