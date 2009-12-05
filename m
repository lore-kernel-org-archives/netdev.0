From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: dst_release() cleanup
Date: Sat, 05 Dec 2009 13:02:13 +0100
Message-ID: <4B1A4BC5.3050300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40339 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754137AbZLEMCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2009 07:02:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

atomic_dec_return() is a full memory barrier, we can omit
the smp_mb__before_atomic_dec() call.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dst.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 57bc4d5..cdec1d1 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -262,13 +262,8 @@ again:
 
 void dst_release(struct dst_entry *dst)
 {
-	if (dst) {
-               int newrefcnt;
-
-		smp_mb__before_atomic_dec();
-               newrefcnt = atomic_dec_return(&dst->__refcnt);
-               WARN_ON(newrefcnt < 0);
-	}
+	if (dst)
+		WARN_ON(atomic_dec_return(&dst->__refcnt) < 0);
 }
 EXPORT_SYMBOL(dst_release);
 
