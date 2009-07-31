From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] mISDN: Read buffer overflow
Date: Fri, 31 Jul 2009 15:43:59 +0200
Message-ID: <4A72F51F.3000503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: isdn@linux-pingi.de, netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:9107 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbZGaNk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2009 09:40:57 -0400
Received: by ey-out-2122.google.com with SMTP id 9so566030eyd.37
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2009 06:40:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check whether index is within bounds before testing the element.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1oip_core.c
index c3b661a..7e5f30d 100644
--- a/drivers/isdn/mISDN/l1oip_core.c
+++ b/drivers/isdn/mISDN/l1oip_core.c
@@ -1480,7 +1480,7 @@ l1oip_init(void)
 		return -ENOMEM;
 
 	l1oip_cnt = 0;
-	while (type[l1oip_cnt] && l1oip_cnt < MAX_CARDS) {
+	while (l1oip_cnt < MAX_CARDS && type[l1oip_cnt]) {
 		switch (type[l1oip_cnt] & 0xff) {
 		case 1:
 			pri = 0;
