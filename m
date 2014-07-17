From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v4 11/11] openvswitch: Add skb_clone NULL check for the sampling action.
Date: Wed, 16 Jul 2014 17:19:29 -0700
Message-ID: <1405556369-1972-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:44641 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755028AbaGQATo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 20:19:44 -0400
Received: by mail-pd0-f171.google.com with SMTP id z10so2084205pdj.30
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 17:19:32 -0700 (PDT)
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
