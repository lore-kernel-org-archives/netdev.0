From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC rocker-net-next 1/6] net: flow: Cancel innermost nested attribute first
Date: Mon,  5 Jan 2015 15:50:05 +0900
Message-ID: <1420440610-20621-2-git-send-email-simon.horman@netronome.com>
References: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:62730 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011AbbAEGuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 01:50:35 -0500
Received: by mail-pd0-f177.google.com with SMTP id ft15so27508966pdb.36
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 22:50:34 -0800 (PST)
In-Reply-To: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cancel innermost nested attribute first on error when putting flow actions.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---

Its unclear to me if this makes any difference.
But it seems more logical to me.
---
 net/core/flow_table.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index 542ebb5..2af831e 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -967,8 +967,8 @@ static int net_flow_put_flow_action(struct sk_buff *skb,
 
 		err = net_flow_put_act_types(skb, a[i].args);
 		if (err) {
-			nla_nest_cancel(skb, action);
 			nla_nest_cancel(skb, sigs);
+			nla_nest_cancel(skb, action);
 			return err;
 		}
 		nla_nest_end(skb, sigs);
-- 
2.1.3
