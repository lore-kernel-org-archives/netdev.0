From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 7/10] ipv6: make icmpv6_route_lookup static
Date: Mon, 16 Dec 2013 10:43:34 -0800
Message-ID: <20131216104334.1b143a90@nehalam.linuxnetplumber.net>
References: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:65030 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755547Ab3LPTkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 14:40:32 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so5919538pbb.4
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 11:40:31 -0800 (PST)
In-Reply-To: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Template table and icmpv6_route_lookup only used in net/ipv6/icmp.c


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/include/net/ipv6.h	2013-12-12 08:46:52.532025877 -0800
+++ b/include/net/ipv6.h	2013-12-12 13:15:14.659040460 -0800
@@ -267,9 +267,6 @@ void icmpv6_notify(struct sk_buff *skb,
 int icmpv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
 			       struct icmp6hdr *thdr, int len);
 
-struct dst_entry *icmpv6_route_lookup(struct net *net, struct sk_buff *skb,
-				      struct sock *sk, struct flowi6 *fl6);
-
 int ip6_ra_control(struct sock *sk, int sel);
 
 int ipv6_parse_hopopts(struct sk_buff *skb);
@@ -841,7 +838,6 @@ static inline int snmp6_unregister_dev(s
 
 #ifdef CONFIG_SYSCTL
 extern struct ctl_table ipv6_route_table_template[];
-extern struct ctl_table ipv6_icmp_table_template[];
 
 struct ctl_table *ipv6_icmp_sysctl_init(struct net *net);
 struct ctl_table *ipv6_route_sysctl_init(struct net *net);
--- a/net/ipv6/icmp.c	2013-10-06 14:48:24.978449730 -0700
+++ b/net/ipv6/icmp.c	2013-12-12 13:15:22.154931148 -0800
@@ -315,8 +315,10 @@ static void mip6_addr_swap(struct sk_buf
 static inline void mip6_addr_swap(struct sk_buff *skb) {}
 #endif
 
-struct dst_entry *icmpv6_route_lookup(struct net *net, struct sk_buff *skb,
-				      struct sock *sk, struct flowi6 *fl6)
+static struct dst_entry *icmpv6_route_lookup(struct net *net,
+					     struct sk_buff *skb,
+					     struct sock *sk,
+					     struct flowi6 *fl6)
 {
 	struct dst_entry *dst, *dst2;
 	struct flowi6 fl2;
@@ -984,7 +986,7 @@ int icmpv6_err_convert(u8 type, u8 code,
 EXPORT_SYMBOL(icmpv6_err_convert);
 
 #ifdef CONFIG_SYSCTL
-struct ctl_table ipv6_icmp_table_template[] = {
+static struct ctl_table ipv6_icmp_table_template[] = {
 	{
 		.procname	= "ratelimit",
 		.data		= &init_net.ipv6.sysctl.icmpv6_time,
