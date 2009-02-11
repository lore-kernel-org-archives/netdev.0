From: akpm@linux-foundation.org
Subject: [patch 2/2] Documentation/connector/cn_test.c: don't use gfp_any()
Date: Wed, 11 Feb 2009 13:27:19 -0800
Message-ID: <200902112127.n1BLRKcv031578@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	andi@firstfloor.org, johnpol@2ka.mipt.ru
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48711 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758747AbZBKV2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 16:28:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

cn_test_timer_func() is a timer handler and can never use GFP_KERNEL -
there's no point in using gfp_any() here.

Also, use setup_timer().

Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 Documentation/connector/cn_test.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff -puN Documentation/connector/cn_test.c~documentation-connector-cn_testc-dont-use-gfp_any Documentation/connector/cn_test.c
--- a/Documentation/connector/cn_test.c~documentation-connector-cn_testc-dont-use-gfp_any
+++ a/Documentation/connector/cn_test.c
@@ -137,7 +137,7 @@ static void cn_test_timer_func(unsigned 
 
 		memcpy(m + 1, data, m->len);
 
-		cn_netlink_send(m, 0, gfp_any());
+		cn_netlink_send(m, 0, GFP_ATOMIC);
 		kfree(m);
 	}
 
@@ -160,10 +160,8 @@ static int cn_test_init(void)
 		goto err_out;
 	}
 
-	init_timer(&cn_test_timer);
-	cn_test_timer.function = cn_test_timer_func;
+	setup_timer(&cn_test_timer, cn_test_timer_func, 0);
 	cn_test_timer.expires = jiffies + HZ;
-	cn_test_timer.data = 0;
 	add_timer(&cn_test_timer);
 
 	return 0;
_
