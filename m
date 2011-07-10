From: Matvejchikov Ilya <matvejchikov@gmail.com>
Subject: Re: [PATCH] slip: fix wrong SLIP6 ifdef-endif placing
Date: Sun, 10 Jul 2011 22:49:26 +0400
Message-ID: <CAKh5nabjFq9RF-CQ_fZd1DG1Ptk7CCtmbknp7Kq6f6HvHmrnxg@mail.gmail.com>
References: <CAKh5nabf9OBG7yb5r=v0bhJLjNJgVrw-hVx9quJ9cwcOXSva=Q@mail.gmail.com>
 <20110710.113741.2147626275846755476.davem@davemloft.net>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:36043 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756483Ab1GJStr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2011 14:49:47 -0400
Received: by qyk29 with SMTP id 29so1043033qyk.19
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2011 11:49:46 -0700 (PDT)
In-Reply-To: <20110710.113741.2147626275846755476.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SLIP6 have nothing to do with CSLIP so placing a block of
SLIP6-related code within a CSLIP ifdef-endif block is incorrect.

Signed-off-by: Ilya Matvejchikov <matvejchikov@gmail.com>
---
 drivers/net/slip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index 8ec1a9a..2f110fb 100644
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

-- 
1.7.4.1
