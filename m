From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] soreuseport: use "unsigned int" in __reuseport_alloc()
Date: Mon, 3 Apr 2017 01:18:23 +0300
Message-ID: <20170402221823.GA4709@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kraig@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:33421 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750853AbdDBWS2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 18:18:28 -0400
Received: by mail-lf0-f66.google.com with SMTP id r36so11475642lfi.0
        for <netdev@vger.kernel.org>; Sun, 02 Apr 2017 15:18:27 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Number of sockets is limited by 16-bit, so 64-bit allocation will never
happen.

16-bit ops are the worst code density-wise on x86_64 because of
additional prefix (66).

Space savings:

	add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-3 (-3)
	function                                     old     new   delta
	reuseport_add_sock                           539     536      -3

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/sock_reuseport.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/net/core/sock_reuseport.c
+++ b/net/core/sock_reuseport.c
@@ -13,9 +13,9 @@
 
 static DEFINE_SPINLOCK(reuseport_lock);
 
-static struct sock_reuseport *__reuseport_alloc(u16 max_socks)
+static struct sock_reuseport *__reuseport_alloc(unsigned int max_socks)
 {
-	size_t size = sizeof(struct sock_reuseport) +
+	unsigned int size = sizeof(struct sock_reuseport) +
 		      sizeof(struct sock *) * max_socks;
 	struct sock_reuseport *reuse = kzalloc(size, GFP_ATOMIC);
 
