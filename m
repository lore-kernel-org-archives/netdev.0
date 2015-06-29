From: subashab@codeaurora.org
Subject: [PATCH] netfilter: nf_nat: Fix possible null dereference
Date: Mon, 29 Jun 2015 17:40:19 -0000
Message-ID: <a1103d923f331e1a067c1f46331449de.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: pablo@netfilter.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45851 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100AbbF2RkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 13:40:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix an issue where __nf_ct_ext_find() could return null to nat in
nf_nat_masquerade_ipv4() and could be dereferenced.

This was detected by static analysis software.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 net/ipv4/netfilter/nf_nat_masquerade_ipv4.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
b/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
index c6eb421..4be5d70 100644
--- a/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
@@ -38,6 +38,8 @@ nf_nat_masquerade_ipv4(struct sk_buff *skb, unsigned int
hooknum,

 	ct = nf_ct_get(skb, &ctinfo);
 	nat = nfct_nat(ct);
+	if (!nat)
+		return NF_DROP;

 	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED ||
 			    ctinfo == IP_CT_RELATED_REPLY));
--
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux
Foundation Collaborative Project
