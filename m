From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [netfilter-next] netfilter: remove unused refcount variable
Date: Mon, 20 Mar 2017 13:37:01 +0100
Message-ID: <20170320123708.4025261-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Liping Zhang <liping.zhang@spreadtrum.com>,
        David Windsor <dwindsor@gmail.com>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Phil Turnbull <phil.turnbull@oracle.com>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The refcount variable was accidentally introduced without any reference
to it. Removing it again avoids this warning:

net/netfilter/nfnetlink_acct.c: In function 'nfnl_acct_try_del':
net/netfilter/nfnetlink_acct.c:329:15: error: unused variable 'refcount' [-Werror=unused-variable]

Fixes: b54ab92b84b6 ("netfilter: refcounter conversions")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/netfilter/nfnetlink_acct.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index f44cbd35357f..c86da174a5fc 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -326,7 +326,6 @@ static int nfnl_acct_get(struct net *net, struct sock *nfnl,
 static int nfnl_acct_try_del(struct nf_acct *cur)
 {
 	int ret = 0;
-	unsigned int refcount;
 
 	/* We want to avoid races with nfnl_acct_put. So only when the current
 	 * refcnt is 1, we decrease it to 0.
-- 
2.9.0
