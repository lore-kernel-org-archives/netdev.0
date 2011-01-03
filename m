From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/1] bridge: stp: ensure mac header is set
Date: Mon,  3 Jan 2011 15:16:28 +0100
Message-ID: <1294064188-17722-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>, acme@ghostprotocols.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:55507 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754191Ab1ACOXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 09:23:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit bf9ae5386bca8836c16e69ab8fdbe46767d7452a
(llc: use dev_hard_header) removed the
skb_reset_mac_header call from llc_mac_hdr_init.

This seems fine itself, but br_send_bpdu() invokes ebtables LOCAL_OUT.

We oops in ebt_basic_match() because it assumes eth_hdr(skb) returns
a meaningful result.

Cc: acme@ghostprotocols.net
References: https://bugzilla.kernel.org/show_bug.cgi?id=24532
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/bridge/br_stp_bpdu.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index 3d9a55d..289646e 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -50,6 +50,8 @@ static void br_send_bpdu(struct net_bridge_port *p,
 
 	llc_mac_hdr_init(skb, p->dev->dev_addr, p->br->group_addr);
 
+	skb_reset_mac_header(skb);
+
 	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
 		dev_queue_xmit);
 }
-- 
1.7.2.2

