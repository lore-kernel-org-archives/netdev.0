From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 153/162] net/ipv6/addrconf.c:503:11: error:
 'struct ipv6_devconf' has no member named 'mc_forwarding'
Date: Tue, 04 Dec 2012 14:47:02 -0500 (EST)
Message-ID: <20121204.144702.1067637950249633761.davem@davemloft.net>
References: <50be5189.raDtevqQSzQSZzon%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54418 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101Ab2LDTrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 14:47:07 -0500
In-Reply-To: <50be5189.raDtevqQSzQSZzon%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks, fixed as follows:

--------------------
[PATCH] ipv6: Protect ->mc_forwarding access with CONFIG_IPV6_MROUTE

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/addrconf.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 28e0e62..6fca01f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -469,8 +469,10 @@ static int inet6_netconf_msgsize_devconf(int type)
 	/* type -1 is used for ALL */
 	if (type == -1 || type == NETCONFA_FORWARDING)
 		size += nla_total_size(4);
+#ifdef CONFIG_IPV6_MROUTE
 	if (type == -1 || type == NETCONFA_MC_FORWARDING)
 		size += nla_total_size(4);
+#endif
 
 	return size;
 }
@@ -498,11 +500,12 @@ static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 	if ((type == -1 || type == NETCONFA_FORWARDING) &&
 	    nla_put_s32(skb, NETCONFA_FORWARDING, devconf->forwarding) < 0)
 		goto nla_put_failure;
+#ifdef CONFIG_IPV6_MROUTE
 	if ((type == -1 || type == NETCONFA_MC_FORWARDING) &&
 	    nla_put_s32(skb, NETCONFA_MC_FORWARDING,
 			devconf->mc_forwarding) < 0)
 		goto nla_put_failure;
-
+#endif
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
-- 
1.7.11.7
