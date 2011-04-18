From: David Miller <davem@davemloft.net>
Subject: [PATCH 27/42] isdn: i4l: isdn_common: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:33:53 -0700 (PDT)
Message-ID: <20110417.173353.233705063.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51066
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754072Ab1DRAe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:29 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id F294424C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'ch' is set but unused in isdn_capi_rec_hl_msg().  Just
kill it off.

Similarly for 'chidx' in isdn_ioctl() and 'di' in
isdn_capi_rec_hl_msg().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/i4l/isdn_common.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_common.c b/drivers/isdn/i4l/isdn_common.c
index 15632bd..6ed82ad 100644
--- a/drivers/isdn/i4l/isdn_common.c
+++ b/drivers/isdn/i4l/isdn_common.c
@@ -399,13 +399,8 @@ isdn_all_eaz(int di, int ch)
 #include <linux/isdn/capicmd.h>
 
 static int
-isdn_capi_rec_hl_msg(capi_msg *cm) {
-	
-	int di;
-	int ch;
-	
-	di = (cm->adr.Controller & 0x7f) -1;
-	ch = isdn_dc2minor(di, (cm->adr.Controller>>8)& 0x7f);
+isdn_capi_rec_hl_msg(capi_msg *cm)
+{
 	switch(cm->Command) {
 		case CAPI_FACILITY:
 			/* in the moment only handled in tty */
@@ -1278,7 +1273,6 @@ isdn_ioctl(struct file *file, uint cmd, ulong arg)
 	uint minor = iminor(file->f_path.dentry->d_inode);
 	isdn_ctrl c;
 	int drvidx;
-	int chidx;
 	int ret;
 	int i;
 	char __user *p;
@@ -1340,7 +1334,6 @@ isdn_ioctl(struct file *file, uint cmd, ulong arg)
 		drvidx = isdn_minor2drv(minor);
 		if (drvidx < 0)
 			return -ENODEV;
-		chidx = isdn_minor2chan(minor);
 		if (!(dev->drv[drvidx]->flags & DRV_FLAG_RUNNING))
 			return -ENODEV;
 		return 0;
-- 
1.7.4.3

