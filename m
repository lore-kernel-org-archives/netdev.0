From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 14/18] irda/irnet: use noop_llseek
Date: Wed,  7 Jul 2010 23:40:16 +0200
Message-ID: <1278538820-1392-15-git-send-email-arnd@arndb.de>
References: <1278538820-1392-1-git-send-email-arnd@arndb.de>
Cc: John Kacur <jkacur@redhat.com>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@lst.de>,
	Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:61792 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757881Ab0GGVk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 17:40:56 -0400
In-Reply-To: <1278538820-1392-1-git-send-email-arnd@arndb.de>
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
 net/irda/irnet/irnet_ppp.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/irda/irnet/irnet_ppp.h b/net/irda/irnet/irnet_ppp.h
index b5df241..7b9949e 100644
--- a/net/irda/irnet/irnet_ppp.h
+++ b/net/irda/irnet/irnet_ppp.h
@@ -104,6 +104,7 @@ static const struct file_operations irnet_device_fops =
 	.unlocked_ioctl	= dev_irnet_ioctl,
 	.open		= dev_irnet_open,
 	.release	= dev_irnet_close
+	.llseek		= noop_llseek,
   /* Also : llseek, readdir, mmap, flush, fsync, fasync, lock, readv, writev */
 };
 
-- 
1.7.1

