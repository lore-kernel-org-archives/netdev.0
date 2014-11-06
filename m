From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 04/14] openvswitch: Remove redundant tcp_flags code.
Date: Thu,  6 Nov 2014 01:19:09 -0800
Message-ID: <1415265549-1640-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Joe Stringer <joestringer@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog137.obsmtp.com ([74.125.149.18]:43425 "HELO
	na3sys009aog137.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751934AbaKFJTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 04:19:12 -0500
Received: by mail-pd0-f173.google.com with SMTP id v10so793863pde.18
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 01:19:11 -0800 (PST)
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
