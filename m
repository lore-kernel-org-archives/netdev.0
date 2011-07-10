From: Matvejchikov Ilya <matvejchikov@gmail.com>
Subject: [PATCH] slip: fix wrong SLIP6 ifdef-endif placing
Date: Sun, 10 Jul 2011 22:32:55 +0400
Message-ID: <CAKh5nabf9OBG7yb5r=v0bhJLjNJgVrw-hVx9quJ9cwcOXSva=Q@mail.gmail.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:40490 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756326Ab1GJSdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2011 14:33:15 -0400
Received: by qyk9 with SMTP id 9so1885310qyk.19
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2011 11:33:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SLIP6 have nothing to do with CSLIP so placing a block of
SLIP6-related code within a CSLIP ifdef-endif block is incorrect.

Signed-off-by: Ilya Matvejchikov <matvejchikov@gmail.com>
---
 drivers/net/slip.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index 8ec1a9a..1ce6e08 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -182,11 +182,11 @@ static int sl_alloc_bufs(struct slip *sl, int mtu)
 #ifdef SL_INCLUDE_CSLIP
 	cbuff = xchg(&sl->cbuff, cbuff);
 	slcomp = xchg(&sl->slcomp, slcomp);
+#endif
 #ifdef CONFIG_SLIP_MODE_SLIP6
 	sl->xdata    = 0;
 	sl->xbits    = 0;
 #endif
-#endif
 	spin_unlock_bh(&sl->lock);
 	err = 0;

@@ -194,8 +194,7 @@ static int sl_alloc_bufs(struct slip *sl, int mtu)
 err_exit:
 #ifdef SL_INCLUDE_CSLIP
 	kfree(cbuff);
-	if (slcomp)
-		slhc_free(slcomp);
+	slhc_free(slcomp);
 #endif
 	kfree(xbuff);
 	kfree(rbuff);
-- 
1.7.4.1
