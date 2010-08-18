From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 1/8]: net: rps: reset network header before calling skb_get_rxhash()
Date: Wed, 18 Aug 2010 13:00:56 +0800
Message-ID: <1282107656-3386-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:50817 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab0HRFBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 01:01:18 -0400
Received: by pwi4 with SMTP id 4so145028pwi.19
        for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 22:01:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_get_rxhash() assumes the network header pointer of the skb is set
properly after the commit: 

commit bfb564e7391340638afe4ad67744a8f3858e7566
Author: Krishna Kumar <krkumar2@in.ibm.com>
Date:   Wed Aug 4 06:15:52 2010 +0000

    core: Factor out flow calculation from get_rps_cpu

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/core/dev.c |    1 +
 1 file changed, 1 insertion(+)
diff --git a/net/core/dev.c b/net/core/dev.c
index 586a11c..382a6d0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2372,6 +2372,7 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 	if (!rxqueue->rps_map && !rxqueue->rps_flow_table)
 		goto done;
 
+	skb_reset_network_header(skb);
 	if (!skb_get_rxhash(skb))
 		goto done;
 
