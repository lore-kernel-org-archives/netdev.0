From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 1/5] openvswitch: Fix memory leak.
Date: Fri, 14 Nov 2014 17:37:29 -0800
Message-ID: <1416015449-1548-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog137.obsmtp.com ([74.125.149.18]:49382 "HELO
	na3sys009aog137.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755172AbaKOBhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 20:37:32 -0500
Received: by mail-pd0-f177.google.com with SMTP id v10so17668392pde.36
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 17:37:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to free memory in case of sample action error.

Introduced by commit 651887b0c22cffcfce7eb9c ("openvswitch: Sample
action without side effects").

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 006886d..00e447a 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -722,8 +722,6 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 
 		case OVS_ACTION_ATTR_SAMPLE:
 			err = sample(dp, skb, key, a);
-			if (unlikely(err)) /* skb already freed. */
-				return err;
 			break;
 		}
 
-- 
1.9.3
