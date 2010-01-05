From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] netfilter: ebtables: enforce CAP_NET_ADMIN
Date: Tue,  5 Jan 2010 19:26:07 +0100
Message-ID: <1262715967-25274-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

normal users are currently allowed to set/modify ebtables rules.
Restrict it to processes with CAP_NET_ADMIN.

Signed-off-by: Florian Westphal <fwestphal@astaro.com>
---
 Note that this cannot be reproduced with
 unmodified ebtables binary because it uses SOCK_RAW.

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index bd1c654..0b7f262 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1406,6 +1406,9 @@ static int do_ebt_set_ctl(struct sock *sk,
 {
 	int ret;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	switch(cmd) {
 	case EBT_SO_SET_ENTRIES:
 		ret = do_replace(sock_net(sk), user, len);
@@ -1425,6 +1428,9 @@ static int do_ebt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	struct ebt_replace tmp;
 	struct ebt_table *t;
 
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
 	if (copy_from_user(&tmp, user, sizeof(tmp)))
 		return -EFAULT;
 
-- 
1.6.3.3

