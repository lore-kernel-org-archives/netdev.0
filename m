From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC rocker-net-next 3/6] net: flow: Remove unnecessary zero-header check when putting a flow
Date: Mon,  5 Jan 2015 15:50:07 +0900
Message-ID: <1420440610-20621-4-git-send-email-simon.horman@netronome.com>
References: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:52964 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095AbbAEGuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 01:50:40 -0500
Received: by mail-pd0-f180.google.com with SMTP id fl12so11963150pdb.11
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 22:50:40 -0800 (PST)
In-Reply-To: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the condition for the for loop to continue.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/core/flow_table.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index 753ebe0..c734a9d 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -1003,9 +1003,6 @@ int net_flow_put_flow(struct sk_buff *skb, struct net_flow_flow *flow)
 		for (j = 0; flow->matches && flow->matches[j].header; j++) {
 			struct net_flow_field_ref *f = &flow->matches[j];
 
-			if (!f->header)
-				continue;
-
 			err = nla_put(skb, NET_FLOW_FIELD_REF, sizeof(*f), f);
 			if (err) {
 				nla_nest_cancel(skb, matches);
-- 
2.1.3
