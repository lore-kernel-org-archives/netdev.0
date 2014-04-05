From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/8] netfilter: Add {ipt,ip6t}_osf aliases for xt_osf
Date: Sat,  5 Apr 2014 18:03:46 +0200
Message-ID: <1396713830-4009-5-git-send-email-pablo@netfilter.org>
References: <1396713830-4009-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1396713830-4009-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kirill Tkhai <ktkhai@parallels.com>

There are no these aliases, so kernel can not request appropriate
match table:

$ iptables -I INPUT -p tcp -m osf --genre Windows --ttl 2 -j DROP
iptables: No chain/target/match by that name.

setsockopt() requests ipt_osf module, which is not present. Add
the aliases.

Signed-off-by: Kirill Tkhai <ktkhai@parallels.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_osf.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 7174611..c529161 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -422,4 +422,6 @@ module_exit(xt_osf_fini);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Evgeniy Polyakov <zbr@ioremap.net>");
 MODULE_DESCRIPTION("Passive OS fingerprint matching.");
+MODULE_ALIAS("ipt_osf");
+MODULE_ALIAS("ip6t_osf");
 MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_OSF);
-- 
1.7.10.4

