From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv6: delete protocol when cleanup
Date: Tue, 18 Nov 2014 18:35:36 +0800
Message-ID: <546B20F8.6010806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:45545 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753861AbaKRKiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 05:38:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pim6_protocol was added when initiation, but it not deleted.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/ip6mr.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 0171f08..6dcdecd 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1439,6 +1439,9 @@ reg_pernet_fail:
 
 void ip6_mr_cleanup(void)
 {
+#ifdef CONFIG_IPV6_PIMSM_V2
+	inet6_del_protocol(&pim6_protocol, IPPROTO_PIM);
+#endif
 	unregister_netdevice_notifier(&ip6_mr_notifier);
 	unregister_pernet_subsys(&ip6mr_net_ops);
 	kmem_cache_destroy(mrt_cachep);
-- 
1.8.3.1
