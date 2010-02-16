From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 31/62: fix build failure with CONNTRACK=y NAT=n
Date: Tue, 16 Feb 2010 15:56:02 +0100 (MET)
Message-ID: <20100216145559.2796.73544.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51997 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932516Ab0BPO4C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:56:02 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 76780373190d7e8ddfb6fed06aef068e2445c743
Author: Florian Westphal <fwestphal@astaro.com>
Date:   Mon Feb 8 15:39:16 2010 +0100

    netfilter: fix build failure with CONNTRACK=y NAT=n
    
    net/ipv4/netfilter/nf_defrag_ipv4.c: In function 'ipv4_conntrack_defrag':
    net/ipv4/netfilter/nf_defrag_ipv4.c:62: error: implicit declaration of function 'nf_ct_is_template'
    
    Signed-off-by: Florian Westphal <fwestphal@astaro.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 77627fa..f6f4668 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -17,6 +17,7 @@
 #include <linux/netfilter_bridge.h>
 #include <linux/netfilter_ipv4.h>
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
+#include <net/netfilter/nf_conntrack.h>
 
 /* Returns new sk_buff, or NULL */
 static int nf_ct_ipv4_gather_frags(struct sk_buff *skb, u_int32_t user)
