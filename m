From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv3 net 3/6] openvswitch: Ensure flow is valid before executing ct
Date: Mon,  5 Oct 2015 15:23:16 -0700
Message-ID: <1444083799-57090-4-git-send-email-joestringer@nicira.com>
References: <1444083799-57090-1-git-send-email-joestringer@nicira.com>
Cc: davem@davemloft.net, pshelar@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35634 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbbJEWX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 18:23:29 -0400
Received: by pacfv12 with SMTP id fv12so192457474pac.2
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 15:23:28 -0700 (PDT)
In-Reply-To: <1444083799-57090-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ct action uses parts of the flow key, so we need to ensure that it
is valid before executing that action.

Fixes: 7f8a436 "openvswitch: Add conntrack action"
Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
v3: No change.
v2: Acked.
---
 net/openvswitch/actions.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 4cb93f92d6be..c6a39bf2c3b9 100644
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
