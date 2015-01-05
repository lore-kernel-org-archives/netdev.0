From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC rocker-net-next 6/6] net: flow: Limit checking of ndo_flow_{set,del}_flows
Date: Mon,  5 Jan 2015 15:50:10 +0900
Message-ID: <1420440610-20621-7-git-send-email-simon.horman@netronome.com>
References: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:37647 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116AbbAEGut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 01:50:49 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so27647246pde.1
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 22:50:48 -0800 (PST)
In-Reply-To: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only check for availability of ndo_flow_{set,del}_flows when
they are to be be used.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/core/flow_table.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index bfc984f..6d620d4 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -1206,9 +1206,20 @@ static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
 	if (!dev)
 		return -EINVAL;
 
-	if (!dev->netdev_ops->ndo_flow_set_flows ||
-	    !dev->netdev_ops->ndo_flow_del_flows)
+	switch (cmd) {
+	case NET_FLOW_TABLE_CMD_SET_FLOWS:
+		if (!dev->netdev_ops->ndo_flow_set_flows)
+			goto out;
+		break;
+
+	case NET_FLOW_TABLE_CMD_DEL_FLOWS:
+		if (!dev->netdev_ops->ndo_flow_del_flows)
+			goto out;
+		break;
+
+	default:
 		goto out;
+	}
 
 	if (!info->attrs[NET_FLOW_IDENTIFIER_TYPE] ||
 	    !info->attrs[NET_FLOW_IDENTIFIER] ||
-- 
2.1.3
