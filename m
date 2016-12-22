From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/2] net/sched: act_tunnel_key: Fix setting UDP dst port in metadata under IPv6
Date: Thu, 22 Dec 2016 14:28:14 +0200
Message-ID: <1482409695-27956-2-git-send-email-ogerlitz@mellanox.com>
References: <1482409695-27956-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roi Dayan <roid@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:58719 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S965502AbcLVM2a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 07:28:30 -0500
In-Reply-To: <1482409695-27956-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The UDP dst port was provided to the helper function which sets the
IPv6 IP tunnel meta-data under a wrong param order, fix that.

Fixes: 75bfbca01e48 ('net/sched: act_tunnel_key: Add UDP dst port option')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 net/sched/act_tunnel_key.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_tunnel_key.c b/net/sched/act_tunnel_key.c
index 7af7125..e3a58e0 100644
--- a/net/sched/act_tunnel_key.c
+++ b/net/sched/act_tunnel_key.c
@@ -134,8 +134,8 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 			saddr = nla_get_in6_addr(tb[TCA_TUNNEL_KEY_ENC_IPV6_SRC]);
 			daddr = nla_get_in6_addr(tb[TCA_TUNNEL_KEY_ENC_IPV6_DST]);
 
-			metadata = __ipv6_tun_set_dst(&saddr, &daddr, 0, 0, 0,
-						      dst_port, TUNNEL_KEY,
+			metadata = __ipv6_tun_set_dst(&saddr, &daddr, 0, 0, dst_port,
+						      0, TUNNEL_KEY,
 						      key_id, 0);
 		}
 
-- 
2.3.7
