From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] X:beyond ARRAY_SIZE of iwb->data
Date: Thu, 21 May 2009 22:05:38 +0200
Message-ID: <4A15B412.8020205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org
To: hjlipp@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:57814 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743AbZEUUFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 16:05:38 -0400
Received: by ewy24 with SMTP id 24so1454091ewy.37
        for <netdev@vger.kernel.org>; Thu, 21 May 2009 13:05:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not go beyond ARRAY_SIZE of iwb->data

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/isdn/gigaset/isocdata.c b/drivers/isdn/gigaset/isocdata.c
index fbce522..5569a6e 100644
--- a/drivers/isdn/gigaset/isocdata.c
+++ b/drivers/isdn/gigaset/isocdata.c
@@ -177,7 +177,7 @@ int gigaset_isowbuf_getbytes(struct isowbuf_t *iwb, int size)
 		return -EINVAL;
 	}
 	src = iwb->read;
-	if (unlikely(limit > BAS_OUTBUFSIZE + BAS_OUTBUFPAD ||
+	if (unlikely(limit >= BAS_OUTBUFSIZE + BAS_OUTBUFPAD ||
 		     (read < src && limit >= src))) {
 		err("isoc write buffer frame reservation violated");
 		return -EFAULT;

