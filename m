From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 1/2] net: sched: act_tunnel_key: request UDP checksum by default
Date: Wed, 14 Jun 2017 21:19:30 +0200
Message-ID: <5fe116fb5ab546a6af1346613737790190b10376.1497467840.git.jbenc@redhat.com>
References: <cover.1497467840.git.jbenc@redhat.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51104 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751756AbdFNTYT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 15:24:19 -0400
In-Reply-To: <cover.1497467840.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's currently no way to request (outer) UDP checksum with
act_tunnel_key. This is problem especially for IPv6. Right now, tunnel_key
action with IPv6 does not work without going through hassles: both sides
have to have udp6zerocsumrx configured on the tunnel interface. This is
obviously not a good solution universally.

It makes more sense to compute the UDP checksum by default even for IPv4.
Just set the default to request the checksum when using act_tunnel_key.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/sched/act_tunnel_key.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_tunnel_key.c b/net/sched/act_tunnel_key.c
index b9a2f241a5b3..b90effa10eb5 100644
--- a/net/sched/act_tunnel_key.c
+++ b/net/sched/act_tunnel_key.c
@@ -125,7 +125,7 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 			daddr = nla_get_in_addr(tb[TCA_TUNNEL_KEY_ENC_IPV4_DST]);
 
 			metadata = __ip_tun_set_dst(saddr, daddr, 0, 0,
-						    dst_port, TUNNEL_KEY,
+						    dst_port, TUNNEL_KEY | TUNNEL_CSUM,
 						    key_id, 0);
 		} else if (tb[TCA_TUNNEL_KEY_ENC_IPV6_SRC] &&
 			   tb[TCA_TUNNEL_KEY_ENC_IPV6_DST]) {
@@ -136,7 +136,7 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 			daddr = nla_get_in6_addr(tb[TCA_TUNNEL_KEY_ENC_IPV6_DST]);
 
 			metadata = __ipv6_tun_set_dst(&saddr, &daddr, 0, 0, dst_port,
-						      0, TUNNEL_KEY,
+						      0, TUNNEL_KEY | TUNNEL_CSUM,
 						      key_id, 0);
 		}
 
-- 
1.8.3.1
