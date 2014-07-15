From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 11/11] openvswitch: Add skb_clone NULL check for the sampling action.
Date: Tue, 15 Jul 2014 10:15:46 -0700
Message-ID: <1405444546-17174-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:36964 "HELO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753322AbaGORPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 13:15:55 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so7235887pab.2
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 10:15:54 -0700 (PDT)
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
