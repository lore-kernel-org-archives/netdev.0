From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 1/4] openvswitch: Fix a double free bug for the sample action
Date: Mon, 30 Jun 2014 23:34:24 -0700
Message-ID: <1404196464-5129-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:36326 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750811AbaGAGea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 02:34:30 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so10027716pab.36
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 23:34:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

When sample action returns with an error, the skb has already been
freed. This patch fix a bug to make sure we don't free it again.
This bug introduced by commit ccb1352e76cff05 (net: Add Open vSwitch
kernel components.)

Signed-off-by: Andy Zhou <azhou@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index c36856a..e70d8b1 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -551,6 +551,8 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 
 		case OVS_ACTION_ATTR_SAMPLE:
 			err = sample(dp, skb, a);
+			if (unlikely(err)) /* skb already freed. */
+				return err;
 			break;
 		}
 
-- 
1.9.3
