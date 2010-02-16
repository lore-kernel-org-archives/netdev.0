From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 12/62: netns:
Date: Tue, 16 Feb 2010 15:55:36 +0100 (MET)
Message-ID: <20100216145534.2796.32992.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51971 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932276Ab0BPOzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:37 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit e9d3897cc2205eec8b7afcc022e4730914b4f48c
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Mon Jan 18 08:08:37 2010 +0100

    netfilter: netns: #ifdef ->iptable_security, ->ip6table_security
    
    'security' tables depend on SECURITY, so ifdef them.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 2eb3814..8098f6b 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -37,7 +37,9 @@ struct netns_ipv4 {
 	struct xt_table		*iptable_mangle;
 	struct xt_table		*iptable_raw;
 	struct xt_table		*arptable_filter;
+#ifdef CONFIG_SECURITY
 	struct xt_table		*iptable_security;
+#endif
 	struct xt_table		*nat_table;
 	struct hlist_head	*nat_bysource;
 	int			nat_vmalloced;
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index dfeb2d7..1f11ebc 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -36,8 +36,10 @@ struct netns_ipv6 {
 	struct xt_table		*ip6table_filter;
 	struct xt_table		*ip6table_mangle;
 	struct xt_table		*ip6table_raw;
+#ifdef CONFIG_SECURITY
 	struct xt_table		*ip6table_security;
 #endif
+#endif
 	struct rt6_info         *ip6_null_entry;
 	struct rt6_statistics   *rt6_stats;
 	struct timer_list       ip6_fib_timer;
