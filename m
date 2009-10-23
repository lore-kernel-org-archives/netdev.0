From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] atm: Cleanup redundant tests on unsigned
Date: Fri, 23 Oct 2009 18:09:55 +0200
Message-ID: <4AE1D553.8010406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Chas Williams <chas@cmf.nrl.navy.mil>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f208.google.com ([209.85.219.208]:63419 "EHLO
	mail-ew0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393AbZJWP7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 11:59:34 -0400
Received: by ewy4 with SMTP id 4so1762141ewy.37
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2009 08:59:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variables are unsigned so the `< 0' test always fails, the
other part of the test catches wrapped values.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 drivers/atm/fore200e.c |    4 ++--
 drivers/atm/he.c       |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index f766cc4..bc53fed 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -2906,8 +2906,8 @@ fore200e_proc_read(struct atm_dev *dev, loff_t* pos, char* page)
 	u32 media_index    = FORE200E_MEDIA_INDEX(fore200e->bus->read(&fore200e->cp_queues->media_type));
 	u32 oc3_index;
 
-	if ((media_index < 0) || (media_index > 4))
-	    media_index = 5;
+	if (media_index > 4)
+		media_index = 5;
 	
 	switch (fore200e->loop_mode) {
 	    case ATM_LM_NONE:    oc3_index = 0;
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 7066703..e906658 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -2739,7 +2739,7 @@ he_ioctl(struct atm_dev *atm_dev, unsigned int cmd, void __user *arg)
 			spin_lock_irqsave(&he_dev->global_lock, flags);
 			switch (reg.type) {
 				case HE_REGTYPE_PCI:
-					if (reg.addr < 0 || reg.addr >= HE_REGMAP_SIZE) {
+					if (reg.addr >= HE_REGMAP_SIZE) {
 						err = -EINVAL;
 						break;
 					}
