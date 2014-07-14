From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH 11/11] openvswitch: Add skb_clone NULL check for the sampling action.
Date: Sun, 13 Jul 2014 17:14:08 -0700
Message-ID: <1405296848-3939-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:47408 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751731AbaGNAOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2014 20:14:18 -0400
Received: by mail-pd0-f174.google.com with SMTP id fp1so879070pdb.5
        for <netdev@vger.kernel.org>; Sun, 13 Jul 2014 17:14:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

Fix a bug where skb_clone() NULL check is missing in sample action
implementation.

Signed-off-by: Andy Zhou <azhou@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 5920512..09ccbb8 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -477,6 +477,8 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 		skb_get(skb);
 	} else {
 		sample_skb = skb_clone(skb, GFP_ATOMIC);
+		if (!sample_skb) /* Skip sample action when out of memory. */
+			return 0;
 	}
 
 	/* Note that do_execute_actions() never consumes skb.
-- 
1.9.3
