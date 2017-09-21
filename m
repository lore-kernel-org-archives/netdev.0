From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: use 32-bit arithmetic while allocating net device
Date: Thu, 21 Sep 2017 23:33:29 +0300
Message-ID: <20170921203329.GA13550@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f177.google.com ([209.85.128.177]:52817 "EHLO
        mail-wr0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751697AbdIUUib (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 16:38:31 -0400
Received: by mail-wr0-f177.google.com with SMTP id c23so5432663wrg.9
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 13:38:31 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Private part of allocation is never big enough to warrant size_t.

Space savings:

	add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-10 (-10)
	function                                     old     new   delta
	alloc_netdev_mqs                            1120    1110     -10

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7989,7 +7989,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 		unsigned int txqs, unsigned int rxqs)
 {
 	struct net_device *dev;
-	size_t alloc_size;
+	unsigned int alloc_size;
 	struct net_device *p;
 
 	BUG_ON(strlen(name) >= sizeof(dev->name));
