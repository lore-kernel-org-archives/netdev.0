From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH 3/6] selinux: replace obsolete NLMSG_* with type safe nlmsg_*
Date: Thu, 28 Mar 2013 00:49:35 +0800
Message-ID: <1364402975-32747-1-git-send-email-honkiko@gmail.com>
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	davem@davemloft.net, tgraf@suug.ch
To: linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 security/selinux/hooks.c   |    4 ++--
 security/selinux/netlink.c |    3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 2fa28c8..0a0609f 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -60,7 +60,7 @@
 #include <linux/bitops.h>
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>	/* for network interface checks */
-#include <linux/netlink.h>
+#include <net/netlink.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/dccp.h>
@@ -4475,7 +4475,7 @@ static int selinux_nlmsg_perm(struct sock *sk, struct sk_buff *skb)
 	struct nlmsghdr *nlh;
 	struct sk_security_struct *sksec = sk->sk_security;
 
-	if (skb->len < NLMSG_SPACE(0)) {
+	if (skb->len < NLMSG_HDRLEN) {
 		err = -EINVAL;
 		goto out;
 	}
diff --git a/security/selinux/netlink.c b/security/selinux/netlink.c
index 14d810e..828fb6a 100644
--- a/security/selinux/netlink.c
+++ b/security/selinux/netlink.c
@@ -16,7 +16,6 @@
 #include <linux/kernel.h>
 #include <linux/export.h>
 #include <linux/skbuff.h>
-#include <linux/netlink.h>
 #include <linux/selinux_netlink.h>
 #include <net/net_namespace.h>
 #include <net/netlink.h>
@@ -77,7 +76,7 @@ static void selnl_notify(int msgtype, void *data)
 
 	len = selnl_msglen(msgtype);
 
-	skb = alloc_skb(NLMSG_SPACE(len), GFP_USER);
+	skb = nlmsg_new(len, GFP_USER);
 	if (!skb)
 		goto oom;
 
-- 
1.7.10.4

