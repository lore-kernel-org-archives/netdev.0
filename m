From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/04: ebtables: enforce CAP_NET_ADMIN
Date: Fri,  8 Jan 2010 17:42:13 +0100 (MET)
Message-ID: <20100108164210.28066.73835.sendpatchset@x2.localnet>
References: <20100108164204.28066.44430.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100108164204.28066.44430.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit dce766af541f6605fa9889892c0280bab31c66ab
Author: Florian Westphal <fwestphal@astaro.com>
Date:   Fri Jan 8 17:31:24 2010 +0100

    netfilter: ebtables: enforce CAP_NET_ADMIN
    
    normal users are currently allowed to set/modify ebtables rules.
    Restrict it to processes with CAP_NET_ADMIN.
    
    Note that this cannot be reproduced with unmodified ebtables binary
    because it uses SOCK_RAW.
    
    Signed-off-by: Florian Westphal <fwestphal@astaro.com>
    Cc: stable@kernel.org
    Signed-off-by: Patrick McHardy <kaber@trash.net>

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
 
