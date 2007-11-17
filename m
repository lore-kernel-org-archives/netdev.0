From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] tun: use iov_length()
Date: Sat, 17 Nov 2007 22:55:00 +0900
Message-ID: <20071117135500.GA14691@APFDCB5C>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vtun@office.satix.net, Maxim Krasnyansky <maxk@qualcomm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.185]:23485 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926AbXKQOA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 09:00:59 -0500
Received: by rv-out-0910.google.com with SMTP id k20so984357rvb
        for <netdev@vger.kernel.org>; Sat, 17 Nov 2007 06:00:58 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use iov_length() instead of tun's homemade iov_total().

Cc: Maxim Krasnyansky <maxk@qualcomm.com>
Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>

---
 drivers/net/tun.c |   15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

Index: 2.6-mm/drivers/net/tun.c
===================================================================
--- 2.6-mm.orig/drivers/net/tun.c
+++ 2.6-mm/drivers/net/tun.c
@@ -292,17 +292,6 @@ static __inline__ ssize_t tun_get_user(s
 	return count;
 }
 
-static inline size_t iov_total(const struct iovec *iv, unsigned long count)
-{
-	unsigned long i;
-	size_t len;
-
-	for (i = 0, len = 0; i < count; i++)
-		len += iv[i].iov_len;
-
-	return len;
-}
-
 static ssize_t tun_chr_aio_write(struct kiocb *iocb, const struct iovec *iv,
 			      unsigned long count, loff_t pos)
 {
@@ -313,7 +302,7 @@ static ssize_t tun_chr_aio_write(struct 
 
 	DBG(KERN_INFO "%s: tun_chr_write %ld\n", tun->dev->name, count);
 
-	return tun_get_user(tun, (struct iovec *) iv, iov_total(iv, count));
+	return tun_get_user(tun, (struct iovec *) iv, iov_length(iv, count));
 }
 
 /* Put packet to the user space buffer */
@@ -364,7 +353,7 @@ static ssize_t tun_chr_aio_read(struct k
 
 	DBG(KERN_INFO "%s: tun_chr_read\n", tun->dev->name);
 
-	len = iov_total(iv, count);
+	len = iov_length(iv, count);
 	if (len < 0)
 		return -EINVAL;
 
