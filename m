From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 36/50] media: usb: em28xx: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:59 +0800
Message-ID: <1373533573-12272-37-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Mauro Carvalho Chehab <mchehab@redhat.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:57518 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932451Ab3GKJL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:11:26 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Mauro Carvalho Chehab <mchehab@redhat.com>
Cc: linux-media@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/media/usb/em28xx/em28xx-core.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/media/usb/em28xx/em28xx-core.c b/drivers/media/usb/em28xx/em28xx-core.c
index fc157af..0d698f9 100644
--- a/drivers/media/usb/em28xx/em28xx-core.c
+++ b/drivers/media/usb/em28xx/em28xx-core.c
@@ -941,6 +941,7 @@ static void em28xx_irq_callback(struct urb *urb)
 {
 	struct em28xx *dev = urb->context;
 	int i;
+	unsigned long flags;
 
 	switch (urb->status) {
 	case 0:             /* success */
@@ -956,9 +957,9 @@ static void em28xx_irq_callback(struct urb *urb)
 	}
 
 	/* Copy data from URB */
-	spin_lock(&dev->slock);
+	spin_lock_irqsave(&dev->slock, flags);
 	dev->usb_ctl.urb_data_copy(dev, urb);
-	spin_unlock(&dev->slock);
+	spin_unlock_irqrestore(&dev->slock, flags);
 
 	/* Reset urb buffers */
 	for (i = 0; i < urb->number_of_packets; i++) {
-- 
1.7.9.5
