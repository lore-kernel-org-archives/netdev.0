From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH v2] ipv6: delete protocol and unregister rtnetlink when cleanup
Date: Wed, 19 Nov 2014 09:35:39 +0800
Message-ID: <546BF3EB.1080603@cn.fujitsu.com>
References: <546B20F8.6010806@cn.fujitsu.com> <CAHA+R7PNmac7KQpSK-vO9zVd3+926f6n_GpaGrbpBnSn98xiyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:51555 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755213AbaKSBiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 20:38:04 -0500
In-Reply-To: <CAHA+R7PNmac7KQpSK-vO9zVd3+926f6n_GpaGrbpBnSn98xiyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



pim6_protocol was added when initiation, but it not deleted.
Similarly, unregister RTNL_FAMILY_IP6MR rtnetlink.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
v2: add missing rtnl_unregister()

 net/ipv6/ip6mr.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 0171f08..1a01d79 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1439,6 +1439,10 @@ reg_pernet_fail:
 
 void ip6_mr_cleanup(void)
 {
+	rtnl_unregister(RTNL_FAMILY_IP6MR, RTM_GETROUTE);
+#ifdef CONFIG_IPV6_PIMSM_V2
+	inet6_del_protocol(&pim6_protocol, IPPROTO_PIM);
+#endif
 	unregister_netdevice_notifier(&ip6_mr_notifier);
 	unregister_pernet_subsys(&ip6mr_net_ops);
 	kmem_cache_destroy(mrt_cachep);
-- 
1.8.3.1
