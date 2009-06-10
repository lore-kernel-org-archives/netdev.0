From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 4/6] drivers/isdn/i4l/isdn_tty.c: fix check for array overindexing
Date: Wed, 10 Jun 2009 12:52:44 -0700
Message-ID: <395df11f5fa7fe852be28ccec8aaa15634386ad1.1244739994.git.keil@b1-systems.de>
References: <cover.1244739994.git.keil@b1-systems.de>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from d112a2.x-mailer.de ([212.162.53.4]:48061 "EHLO
	d112a2.x-mailer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753273AbZFKR2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 13:28:51 -0400
In-Reply-To: <cover.1244739994.git.keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

The check for overindexing of dev->mdm.info[] has an off-by-one.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/i4l/isdn_tty.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
index 1a2222c..b4d4522 100644
--- a/drivers/isdn/i4l/isdn_tty.c
+++ b/drivers/isdn/i4l/isdn_tty.c
@@ -1592,7 +1592,7 @@ isdn_tty_open(struct tty_struct *tty, struct file *filp)
 	int retval, line;
 
 	line = tty->index;
-	if (line < 0 || line > ISDN_MAX_CHANNELS)
+	if (line < 0 || line >= ISDN_MAX_CHANNELS)
 		return -ENODEV;
 	info = &dev->mdm.info[line];
 	if (isdn_tty_paranoia_check(info, tty->name, "isdn_tty_open"))
-- 
1.6.0.2

