From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 08/15] irda/irnet: use noop_llseek
Date: Tue, 14 Sep 2010 22:22:36 +0200
Message-ID: <1284495763-7506-9-git-send-email-arnd@arndb.de>
References: <1284495763-7506-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Samuel Ortiz <samuel@sortiz.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:60119 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755282Ab0INUXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 16:23:20 -0400
In-Reply-To: <1284495763-7506-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There may be applications trying to seek
on the irnet character device, so we should
use noop_llseek to avoid returning an error
when the default llseek changes to no_llseek.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: netdev@vger.kernel.org
---
 net/irda/irnet/irnet_ppp.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/irda/irnet/irnet_ppp.h b/net/irda/irnet/irnet_ppp.h
index b5df241..9402258 100644
--- a/net/irda/irnet/irnet_ppp.h
+++ b/net/irda/irnet/irnet_ppp.h
@@ -103,7 +103,8 @@ static const struct file_operations irnet_device_fops =
 	.poll		= dev_irnet_poll,
 	.unlocked_ioctl	= dev_irnet_ioctl,
 	.open		= dev_irnet_open,
-	.release	= dev_irnet_close
+	.release	= dev_irnet_close,
+	.llseek		= noop_llseek,
   /* Also : llseek, readdir, mmap, flush, fsync, fasync, lock, readv, writev */
 };
 
-- 
1.7.1

