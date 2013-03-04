From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -v3 22/23] net: rename random32 to prandom
Date: Mon,  4 Mar 2013 21:58:30 +0900
Message-ID: <1362401911-14074-23-git-send-email-akinobu.mita@gmail.com>
References: <1362401911-14074-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:63715 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758119Ab3CDNAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 08:00:05 -0500
In-Reply-To: <1362401911-14074-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 496f2f93b1cc286f5a4f4f9acdc1e5314978683f ("random32: rename
random32 to prandom") renamed random32() and srandom32() to prandom_u32()
and prandom_seed() respectively.

net_random() and net_srandom() need to be redefined with prandom_* in
order to finish the naming transition.

While I'm at it, enclose macro argument of net_srandom() with parenthesis.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---

No change from v2

 include/linux/net.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index aa16731..99c9f0c 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -240,8 +240,8 @@ do {								\
 #define net_dbg_ratelimited(fmt, ...)				\
 	net_ratelimited_function(pr_debug, fmt, ##__VA_ARGS__)
 
-#define net_random()		random32()
-#define net_srandom(seed)	srandom32((__force u32)seed)
+#define net_random()		prandom_u32()
+#define net_srandom(seed)	prandom_seed((__force u32)(seed))
 
 extern int   	     kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 				    struct kvec *vec, size_t num, size_t len);
-- 
1.8.1.2
