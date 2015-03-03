From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2] net: bridge: add compile-time assert for cb struct size
Date: Tue,  3 Mar 2015 13:53:31 +0100
Message-ID: <1425387211-16807-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:57016 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755869AbbCCMxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 07:53:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

make build fail if structure no longer fits into ->cb storage.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Change since v1: use FIELD_SIZEOF

 checkpatch complains about >80 chars, but line break is ugly here.

diff --git a/net/bridge/br.c b/net/bridge/br.c
index fb57ab6..02c24cf 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -190,6 +190,8 @@ static int __init br_init(void)
 {
 	int err;
 
+	BUILD_BUG_ON(sizeof(struct br_input_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));
+
 	err = stp_proto_register(&br_stp_proto);
 	if (err < 0) {
 		pr_err("bridge: can't register sap for STP\n");
-- 
2.0.5
