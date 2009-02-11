From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] sun3: print when lance_open() fails
Date: Wed, 11 Feb 2009 16:14:09 +0100
Message-ID: <4992EB41.1030405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: sammy@sammy.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f11.google.com ([209.85.221.11]:43912 "EHLO
	mail-qy0-f11.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754895AbZBKPVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 10:21:51 -0500
Received: by qyk4 with SMTP id 4so242233qyk.13
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2009 07:21:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With while (--i > 0) { ... } i reaches 0; print when lance_open() fails

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index 4bb8f72..e5beb29 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -428,7 +428,7 @@ static int lance_open( struct net_device *dev )
 	while (--i > 0)
 		if (DREG & CSR0_IDON)
 			break;
-	if (i < 0 || (DREG & CSR0_ERR)) {
+	if (i <= 0 || (DREG & CSR0_ERR)) {
 		DPRINTK( 2, ( "lance_open(): opening %s failed, i=%d, csr0=%04x\n",
 					  dev->name, i, DREG ));
 		DREG = CSR0_STOP;
