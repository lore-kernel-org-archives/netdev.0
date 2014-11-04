From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 04/14] openvswitch: Remove redundant tcp_flags code.
Date: Mon,  3 Nov 2014 22:01:06 -0800
Message-ID: <1415080866-1750-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Joe Stringer <joestringer@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog005.obsmtp.com ([74.125.150.50]:44500 "HELO
	na6sys009bog005.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751983AbaKEUBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:01:22 -0500
Received: by mail-pa0-f46.google.com with SMTP id lf10so1429463pab.5
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 12:01:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>

These two cases used to be treated differently for IPv4/IPv6,
but they are now identical.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Jarno Rajahalme <jrajahalme@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/flow_netlink.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 569309c..5a91d79 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -611,7 +611,6 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 				const struct nlattr **a, bool is_mask)
 {
 	int err;
-	u64 orig_attrs = attrs;
 
 	err = metadata_from_nlattrs(match, &attrs, a, is_mask);
 	if (err)
@@ -764,15 +763,9 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 	}
 
 	if (attrs & (1 << OVS_KEY_ATTR_TCP_FLAGS)) {
-		if (orig_attrs & (1 << OVS_KEY_ATTR_IPV4)) {
-			SW_FLOW_KEY_PUT(match, tp.flags,
-					nla_get_be16(a[OVS_KEY_ATTR_TCP_FLAGS]),
-					is_mask);
-		} else {
-			SW_FLOW_KEY_PUT(match, tp.flags,
-					nla_get_be16(a[OVS_KEY_ATTR_TCP_FLAGS]),
-					is_mask);
-		}
+		SW_FLOW_KEY_PUT(match, tp.flags,
+				nla_get_be16(a[OVS_KEY_ATTR_TCP_FLAGS]),
+				is_mask);
 		attrs &= ~(1 << OVS_KEY_ATTR_TCP_FLAGS);
 	}
 
-- 
1.9.3
