From: akpm@linux-foundation.org
Subject: [patch 7/7] rfcomm tty: destroy before tty_close()
Date: Mon, 04 Feb 2008 23:48:20 -0800
Message-ID: <200802050748.m157m1v2010470@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	hidave.darkstar@gmail.com
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42067 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753700AbYBEHsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 02:48:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Young <hidave.darkstar@gmail.com>

rfcomm dev could be deleted in tty_hangup, so we must not call
rfcomm_dev_del again to prevent from destroying rfcomm dev before tty
close.

Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
Cc: Marcel Holtmann <marcel@holtmann.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/bluetooth/rfcomm/tty.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN net/bluetooth/rfcomm/tty.c~rfcomm-tty-destroy-before-tty_close net/bluetooth/rfcomm/tty.c
--- a/net/bluetooth/rfcomm/tty.c~rfcomm-tty-destroy-before-tty_close
+++ a/net/bluetooth/rfcomm/tty.c
@@ -429,7 +429,8 @@ static int rfcomm_release_dev(void __use
 	if (dev->tty)
 		tty_vhangup(dev->tty);
 
-	rfcomm_dev_del(dev);
+	if (!test_bit(RFCOMM_RELEASE_ONHUP, &dev->flags))
+		rfcomm_dev_del(dev);
 	rfcomm_dev_put(dev);
 	return 0;
 }
_
