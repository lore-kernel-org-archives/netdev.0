From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next v2] unix: convert printks to pr_<level>
Date: Fri, 6 Dec 2013 18:03:36 +0800
Message-ID: <52A1A0F8.9080506@huawei.com>
References: <52A16A19.60001@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <edumazet@google.com>, <ebiederm@xmission.com>,
	<gaofeng@cn.fujitsu.com>, <jacob.e.keller@intel.com>,
	<netdev@vger.kernel.org>, Daniel Borkmann <dborkman@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:2135 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961Ab3LFKEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 05:04:10 -0500
In-Reply-To: <52A16A19.60001@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use pr_<level> instead of printk(LEVEL)

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/unix/af_unix.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 01625cc..8136222 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -80,6 +80,8 @@
  *		  with BSD names.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/signal.h>
@@ -366,7 +368,7 @@ static void unix_sock_destructor(struct sock *sk)
 	WARN_ON(!sk_unhashed(sk));
 	WARN_ON(sk->sk_socket);
 	if (!sock_flag(sk, SOCK_DEAD)) {
-		printk(KERN_INFO "Attempt to release alive unix socket: %p\n", sk);
+		pr_info("Attempt to release alive unix socket: %p\n", sk);
 		return;
 	}
 
@@ -378,7 +380,7 @@ static void unix_sock_destructor(struct sock *sk)
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 	local_bh_enable();
 #ifdef UNIX_REFCNT_DEBUG
-	printk(KERN_DEBUG "UNIX %p is destroyed, %ld are still alive.\n", sk,
+	pr_debug("UNIX %p is destroyed, %ld are still alive.\n", sk,
 		atomic_long_read(&unix_nr_socks));
 #endif
 }
@@ -2433,8 +2435,7 @@ static int __init af_unix_init(void)
 
 	rc = proto_register(&unix_proto, 1);
 	if (rc != 0) {
-		printk(KERN_CRIT "%s: Cannot create unix_sock SLAB cache!\n",
-		       __func__);
+		pr_crit("%s: Cannot create unix_sock SLAB cache!\n", __func__);
 		goto out;
 	}
 
-- 
1.7.12
