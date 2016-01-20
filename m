From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/6] netfilter: ipset: allow a 0 netmask with hash_netiface type
Date: Wed, 20 Jan 2016 18:04:00 +0100
Message-ID: <1453309444-2297-3-git-send-email-pablo@netfilter.org>
References: <1453309444-2297-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45492 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934862AbcATREZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2016 12:04:25 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 815A3A7E31
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 18:04:22 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 74A9EDA7E0
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 18:04:22 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id DE967DA80C
	for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 18:04:18 +0100 (CET)
In-Reply-To: <1453309444-2297-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Jozsef says:
 The correct behaviour is that if we have
 ipset create test1 hash:net,iface
 ipset add test1 0.0.0.0/0,eth0
 iptables -A INPUT -m set --match-set test1 src,src

 then the rule should match for any traffic coming in through eth0.

This removes the -EINVAL runtime test to make matching work
in case packet arrived via the specified interface.

Bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=1297092
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_netiface.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 43d8c98..f0f688d 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -164,8 +164,6 @@ hash_netiface4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	};
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
-	if (e.cidr == 0)
-		return -EINVAL;
 	if (adt == IPSET_TEST)
 		e.cidr = HOST_MASK;
 
@@ -377,8 +375,6 @@ hash_netiface6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	};
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
-	if (e.cidr == 0)
-		return -EINVAL;
 	if (adt == IPSET_TEST)
 		e.cidr = HOST_MASK;
 
-- 
2.1.4
