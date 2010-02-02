From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/02: ctnetlink: fix expectation mask dump
Date: Tue,  2 Feb 2010 17:27:39 +0100 (MET)
Message-ID: <20100202162739.24867.40412.sendpatchset@x2.localnet>
References: <20100202162736.24867.67227.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33301 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755015Ab0BBQ1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 11:27:41 -0500
In-Reply-To: <20100202162736.24867.67227.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit e578756c35859a459d78d8416195bc5f5ff897d0
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Jan 26 17:04:02 2010 +0100

    netfilter: ctnetlink: fix expectation mask dump
    
    The protocol number is not initialized, so userspace can't interpret
    the layer 4 data properly.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 59d8064..42f21c0 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1437,8 +1437,9 @@ ctnetlink_exp_dump_mask(struct sk_buff *skb,
 	struct nlattr *nest_parms;
 
 	memset(&m, 0xFF, sizeof(m));
-	m.src.u.all = mask->src.u.all;
 	memcpy(&m.src.u3, &mask->src.u3, sizeof(m.src.u3));
+	m.src.u.all = mask->src.u.all;
+	m.dst.protonum = tuple->dst.protonum;
 
 	nest_parms = nla_nest_start(skb, CTA_EXPECT_MASK | NLA_F_NESTED);
 	if (!nest_parms)
