From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 09/30] ipv4: Remember the net in ip_output and ip_mc_output
Date: Tue, 15 Sep 2015 20:03:57 -0500
Message-ID: <1442365458-16349-9-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a prepatory patch to passing net int the netfilter hooks,
where net will be used again.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/ip_output.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index f076f11aa94a..9ee622ad8dfa 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -288,11 +288,12 @@ int ip_mc_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct rtable *rt = skb_rtable(skb);
 	struct net_device *dev = rt->dst.dev;
+	struct net *net = dev_net(dev);
 
 	/*
 	 *	If the indicated interface is up and running, send the packet.
 	 */
-	IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
+	IP_UPD_PO_STATS(net, IPSTATS_MIB_OUT, skb->len);
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
@@ -347,8 +348,9 @@ int ip_mc_output(struct sock *sk, struct sk_buff *skb)
 int ip_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb_dst(skb)->dev;
+	struct net *net = dev_net(dev);
 
-	IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
+	IP_UPD_PO_STATS(net, IPSTATS_MIB_OUT, skb->len);
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
-- 
2.2.1

