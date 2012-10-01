From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] gre: fix sparse warning
Date: Mon, 1 Oct 2012 08:21:14 -0700
Message-ID: <20121001082114.0803f6d1@nehalam.linuxnetplumber.net>
References: <20120929011210.GA10053@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35488 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751462Ab2JAPVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 11:21:51 -0400
In-Reply-To: <20120929011210.GA10053@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use be16 consistently when looking at flags.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/ip_gre.c	2012-09-27 15:47:35.076895836 -0700
+++ b/net/ipv4/ip_gre.c	2012-10-01 08:18:50.990145746 -0700
@@ -222,7 +222,7 @@ static struct rtnl_link_stats64 *ipgre_g
 
 /* Does key in tunnel parameters match packet */
 static bool ipgre_key_match(const struct ip_tunnel_parm *p,
-			    __u32 flags, __be32 key)
+			    __be16 flags, __be32 key)
 {
 	if (p->i_flags & GRE_KEY) {
 		if (flags & GRE_KEY)
@@ -237,7 +237,7 @@ static bool ipgre_key_match(const struct
 
 static struct ip_tunnel *ipgre_tunnel_lookup(struct net_device *dev,
 					     __be32 remote, __be32 local,
-					     __u32 flags, __be32 key,
+					     __be16 flags, __be32 key,
 					     __be16 gre_proto)
 {
 	struct net *net = dev_net(dev);
