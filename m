From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 6/6] openvswitch: Remove ovs_vport_output_sk
Date: Wed, 30 Sep 2015 16:25:36 -0500
Message-ID: <1443648336-31741-6-git-send-email-ebiederm@xmission.com>
References: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:45901 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754550AbbI3VeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 17:34:25 -0400
In-Reply-To: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was a compatibility function needed while the ipv4 and ipv6
fragmentation code was being modified to pass a struct net through
them.  Now that is complete this function has no more users so remove
it.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/openvswitch/actions.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index f33c627f97b3..1d21ab9d2b5c 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -645,11 +645,6 @@ static int ovs_vport_output(struct net *net, struct sock *sk, struct sk_buff *sk
 	ovs_vport_send(vport, skb);
 	return 0;
 }
-static int ovs_vport_output_sk(struct sock *sk, struct sk_buff *skb)
-{
-	struct net *net = dev_net(skb_dst(skb)->dev);
-	return ovs_vport_output(net, sk, skb);
-}
 
 static unsigned int
 ovs_dst_get_mtu(const struct dst_entry *dst)
-- 
2.2.1
