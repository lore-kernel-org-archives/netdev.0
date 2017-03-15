From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/openvswitch: Set the ipv6 source tunnel key address attribute correctly
Date: Wed, 15 Mar 2017 18:10:47 +0200
Message-ID: <1489594247-8601-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jiri Benc <jbenc@redhat.com>, Paul Blakey <paulb@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, mlxsw@mellanox.com,
        netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46529 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752220AbdCOQK6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 12:10:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When dealing with ipv6 source tunnel key address attribute
(OVS_TUNNEL_KEY_ATTR_IPV6_SRC) we are wrongly setting the tunnel
dst ip, fix that.

Fixes: 6b26ba3a7d95 ('openvswitch: netlink attributes for IPv6 tunneling')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Paul Blakey <paulb@mellanox.com>
---

Jiri, so I have few wild guesses how things work w.o this fix, e.g: 

(1) typically the tunnel source ip attribute isn't set by user-space
(2) the vxlan driver overrides the source ip from what they get after 
    route lookup on the dest
(3) more?

 net/openvswitch/flow_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 6f5fa50..a08ff83 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -604,7 +604,7 @@ static int ip_tun_from_nlattr(const struct nlattr *attr,
 			ipv4 = true;
 			break;
 		case OVS_TUNNEL_KEY_ATTR_IPV6_SRC:
-			SW_FLOW_KEY_PUT(match, tun_key.u.ipv6.dst,
+			SW_FLOW_KEY_PUT(match, tun_key.u.ipv6.src,
 					nla_get_in6_addr(a), is_mask);
 			ipv6 = true;
 			break;
-- 
2.3.7
