From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC rocker-net-next 5/6] net: flow: Return more fine-grained error when handing flows commands
Date: Mon,  5 Jan 2015 15:50:09 +0900
Message-ID: <1420440610-20621-6-git-send-email-simon.horman@netronome.com>
References: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:58467 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116AbbAEGuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 01:50:46 -0500
Received: by mail-pd0-f172.google.com with SMTP id y13so27707036pdi.3
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 22:50:45 -0800 (PST)
In-Reply-To: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net_flow_table_cmd_flows() sets err to various error values
before returning err. It seems as well to return the value.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/core/flow_table.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index 1a32a72..bfc984f 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -1285,7 +1285,7 @@ out:
 	if (skb)
 		nlmsg_free(skb);
 	dev_put(dev);
-	return -EINVAL;
+	return err;
 }
 
 static const struct nla_policy net_flow_cmd_policy[NET_FLOW_MAX + 1] = {
-- 
2.1.3
