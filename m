From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: make in_aton() 32-bit internally
Date: Fri, 24 Mar 2017 00:58:26 +0300
Message-ID: <20170323215826.GA31372@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:33289 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750761AbdCWV6e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 17:58:34 -0400
Received: by mail-lf0-f66.google.com with SMTP id r36so18311105lfi.0
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 14:58:33 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting IPv4 address doesn't need 64-bit arithmetic.

Space savings: 10 bytes!

	add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-10 (-10)
	function                          old     new   delta
	in_aton                            96      86     -10

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/utils.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -51,7 +51,7 @@ EXPORT_SYMBOL(net_ratelimit);
 
 __be32 in_aton(const char *str)
 {
-	unsigned long l;
+	unsigned int l;
 	unsigned int val;
 	int i;
 
