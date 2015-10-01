From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 4/7] openvswitch: Ensure flow is valid before executing ct
Date: Thu,  1 Oct 2015 13:53:27 -0700
Message-ID: <1443732810-38746-5-git-send-email-joestringer@nicira.com>
References: <1443732810-38746-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, jesse@nicira.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35694 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756675AbbJAUxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 16:53:40 -0400
Received: by pacfv12 with SMTP id fv12so86621989pac.2
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 13:53:39 -0700 (PDT)
In-Reply-To: <1443732810-38746-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ct action uses parts of the flow key, so we need to ensure that it
is valid before executing that action.

Fixes: 7f8a436 "openvswitch: Add conntrack action"
Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
v2: Acked.
---
 net/openvswitch/actions.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 4cb93f9..c6a39bf 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -1102,6 +1102,12 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			break;
 
 		case OVS_ACTION_ATTR_CT:
+			if (!is_flow_key_valid(key)) {
+				err = ovs_flow_key_update(skb, key);
+				if (err)
+					return err;
+			}
+
 			err = ovs_ct_execute(ovs_dp_get_net(dp), skb, key,
 					     nla_data(a));
 
-- 
2.1.4
