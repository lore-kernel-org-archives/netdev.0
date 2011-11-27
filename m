From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH] isdn/gigaset: report ISDN4Linux interface only once
Date: Sun, 27 Nov 2011 18:39:22 +0100
Message-ID: <20111127-patch-gigaset-01.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the "ISDN4Linux interface" message from device registration,
where it is emitted for each device, to driver registration, where
it is emitted only once, for consistency with the CAPI variant.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/i4l.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index 04231cb..1793ba1 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -624,8 +624,6 @@ int gigaset_isdn_regdev(struct cardstate *cs, const char *isdnid)
 {
 	isdn_if *iif;
 
-	pr_info("ISDN4Linux interface\n");
-
 	iif = kmalloc(sizeof *iif, GFP_KERNEL);
 	if (!iif) {
 		pr_err("out of memory\n");
@@ -684,6 +682,7 @@ void gigaset_isdn_unregdev(struct cardstate *cs)
  */
 void gigaset_isdn_regdrv(void)
 {
+	pr_info("ISDN4Linux interface\n");
 	/* nothing to do */
 }
 
-- 
1.7.3.4
