From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: change IPS_*_BIT to IPS_*
Date: Sun, 21 Nov 2010 08:13:15 +0800
Message-ID: <1290298395-20160-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>,
	Tim Gardner <tim.gardner@canonical.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:48372 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610Ab0KUAON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Nov 2010 19:14:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My previous patch made a mistake when converting atomic_set to a normal
bit 'or'. IPS_*_BIT should be replaced with IPS_*.

  commit 76a2d3bcfcc86e2a8044258515b86492a37631a3
  Author: Changli Gao <xiaosuo@gmail.com>
  Date:   Mon Nov 15 11:59:03 2010 +0100

  netfilter: nf_nat: don't use atomic bit operation

  As we own the conntrack and the others can't see it until we confirm it,
  we don't need to use atomic bit operation on ct->status.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Cc: Tim Gardner <tim.gardner@canonical.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/netfilter/nf_nat_core.h |    4 ++--
 net/ipv4/netfilter/nf_nat_core.c    |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)
diff --git a/include/net/netfilter/nf_nat_core.h b/include/net/netfilter/nf_nat_core.h
index 5aec85c..3dc7b98 100644
--- a/include/net/netfilter/nf_nat_core.h
+++ b/include/net/netfilter/nf_nat_core.h
@@ -21,9 +21,9 @@ static inline int nf_nat_initialized(struct nf_conn *ct,
 				     enum nf_nat_manip_type manip)
 {
 	if (manip == IP_NAT_MANIP_SRC)
-		return ct->status & IPS_SRC_NAT_DONE_BIT;
+		return ct->status & IPS_SRC_NAT_DONE;
 	else
-		return ct->status & IPS_DST_NAT_DONE_BIT;
+		return ct->status & IPS_DST_NAT_DONE;
 }
 
 struct nlattr;
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index eb55835..21e6e92 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -323,9 +323,9 @@ nf_nat_setup_info(struct nf_conn *ct,
 
 	/* It's done. */
 	if (maniptype == IP_NAT_MANIP_DST)
-		ct->status |= IPS_DST_NAT_DONE_BIT;
+		ct->status |= IPS_DST_NAT_DONE;
 	else
-		ct->status |= IPS_SRC_NAT_DONE_BIT;
+		ct->status |= IPS_SRC_NAT_DONE;
 
 	return NF_ACCEPT;
 }
