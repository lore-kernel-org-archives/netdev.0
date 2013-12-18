From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/3] netconf: rename PROXY_ARP to NEIGH_PROXY
Date: Tue, 17 Dec 2013 22:35:52 -0800
Message-ID: <20131217223552.60d1f5cb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34903 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab3LRGjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 01:39:12 -0500
Received: by mail-pa0-f43.google.com with SMTP id bj1so5540822pad.2
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 22:39:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use same field for both IPv4 (proxy_arp) and IPv6 (proxy_ndp)
so fix it before API is set to be a common name

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 include/uapi/linux/netconf.h |    2 +-
 net/ipv4/devinet.c           |   10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

--- a/include/uapi/linux/netconf.h	2013-12-17 22:30:00.000000000 -0800
+++ b/include/uapi/linux/netconf.h	2013-12-17 22:31:07.973419694 -0800
@@ -14,7 +14,7 @@ enum {
 	NETCONFA_FORWARDING,
 	NETCONFA_RP_FILTER,
 	NETCONFA_MC_FORWARDING,
-	NETCONFA_PROXY_ARP,
+	NETCONFA_PROXY_NEIGH,
 	__NETCONFA_MAX
 };
 #define NETCONFA_MAX	(__NETCONFA_MAX - 1)
--- a/net/ipv4/devinet.c	2013-12-17 22:30:00.000000000 -0800
+++ b/net/ipv4/devinet.c	2013-12-17 22:31:07.973419694 -0800
@@ -1696,7 +1696,7 @@ static int inet_netconf_msgsize_devconf(
 		size += nla_total_size(4);
 	if (type == -1 || type == NETCONFA_MC_FORWARDING)
 		size += nla_total_size(4);
-	if (type == -1 || type == NETCONFA_PROXY_ARP)
+	if (type == -1 || type == NETCONFA_PROXY_NEIGH)
 		size += nla_total_size(4);
 
 	return size;
@@ -1734,8 +1734,8 @@ static int inet_netconf_fill_devconf(str
 	    nla_put_s32(skb, NETCONFA_MC_FORWARDING,
 			IPV4_DEVCONF(*devconf, MC_FORWARDING)) < 0)
 		goto nla_put_failure;
-	if ((type == -1 || type == NETCONFA_PROXY_ARP) &&
-	    nla_put_s32(skb, NETCONFA_PROXY_ARP,
+	if ((type == -1 || type == NETCONFA_PROXY_NEIGH) &&
+	    nla_put_s32(skb, NETCONFA_PROXY_NEIGH,
 			IPV4_DEVCONF(*devconf, PROXY_ARP)) < 0)
 		goto nla_put_failure;
 
@@ -1775,7 +1775,7 @@ static const struct nla_policy devconf_i
 	[NETCONFA_IFINDEX]	= { .len = sizeof(int) },
 	[NETCONFA_FORWARDING]	= { .len = sizeof(int) },
 	[NETCONFA_RP_FILTER]	= { .len = sizeof(int) },
-	[NETCONFA_PROXY_ARP]	= { .len = sizeof(int) },
+	[NETCONFA_PROXY_NEIGH]	= { .len = sizeof(int) },
 };
 
 static int inet_netconf_get_devconf(struct sk_buff *in_skb,
@@ -2002,7 +2002,7 @@ static int devinet_conf_proc(struct ctl_
 		if (i == IPV4_DEVCONF_PROXY_ARP - 1 &&
 		    new_value != old_value) {
 			ifindex = devinet_conf_ifindex(net, cnf);
-			inet_netconf_notify_devconf(net, NETCONFA_PROXY_ARP,
+			inet_netconf_notify_devconf(net, NETCONFA_PROXY_NEIGH,
 						    ifindex, cnf);
 		}
 	}
