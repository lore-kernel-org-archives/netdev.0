From: Liu Hua <sdu.liu@huawei.com>
Subject: [PATCH] netfilter: fix dependency issues between IPv6 defragmentation and ip6tables
Date: Sun,  3 May 2015 17:50:18 +0800
Message-ID: <1430646618-7625-1-git-send-email-sdu.liu@huawei.com>
Cc: sdu.liu@huawei.com, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, liusdu@126.com
To: davem@davemloft.net, kadlec@blackhole.kfki.hu, kaber@trash.net,
	pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit f6318e558806c925029dc101f14874be9f9fa78f fix some related issue
when ip6tables is enabled. But when IP6_NF_IPTABLES is disabled and
NETFILTER_XT_TARGET_TPROXY is enabled. We will meet build failure with
"net/built-in.o: In function `tproxy_tg_init':
net/netfilter/xt_TPROXY.c:588: undefined reference to `nf_defrag_ipv6_enable'
"
So this patch change the Kconfig as ipv4 does.

Signed-off-by: Liu Hua <sdu.liu@huawei.com>
---
 net/netfilter/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index f70e34a..34f54a8 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -865,7 +865,7 @@ config NETFILTER_XT_TARGET_TPROXY
 	depends on (IPV6 || IPV6=n)
 	depends on IP_NF_MANGLE
 	select NF_DEFRAG_IPV4
-	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
+	select NF_DEFRAG_IPV6
 	help
 	  This option adds a `TPROXY' target, which is somewhat similar to
 	  REDIRECT.  It can only be used in the mangle table and is useful
-- 
1.9.1


