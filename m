From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] net: bridge: add compile-time assert for cb struct size
Date: Tue,  3 Mar 2015 03:50:22 +0100
Message-ID: <1425351022-5415-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:55646 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753735AbbCCCub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 21:50:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

make build fail if struct doesn't fit into ->cb storage area.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/bridge/br.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/bridge/br.c b/net/bridge/br.c
index fb57ab6..9542c53 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -188,8 +188,11 @@ static const struct stp_proto br_stp_proto = {
 
 static int __init br_init(void)
 {
+	struct sk_buff *skb;
 	int err;
 
+	BUILD_BUG_ON(sizeof(struct br_input_skb_cb) > sizeof(skb->cb));
+
 	err = stp_proto_register(&br_stp_proto);
 	if (err < 0) {
 		pr_err("bridge: can't register sap for STP\n");
-- 
2.0.5
