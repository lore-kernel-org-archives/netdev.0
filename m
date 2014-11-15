From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 5/5] openvswitch: Validate IPv6 flow key and mask values.
Date: Fri, 14 Nov 2014 17:38:08 -0800
Message-ID: <1416015488-1667-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Jarno Rajahalme <jrajahalme@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:55967 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965255AbaKOBiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 20:38:11 -0500
Received: by mail-pd0-f171.google.com with SMTP id r10so17690571pdi.16
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 17:38:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jrajahalme@nicira.com>

Reject flow label key and mask values with invalid bits set.
Introduced by commit 3fdbd1ce11e5 ("openvswitch: add ipv6 'set'
action").

Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
Acked-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/flow_netlink.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index dda040e..fa4ec2e 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -689,6 +689,13 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 				ipv6_key->ipv6_frag, OVS_FRAG_TYPE_MAX);
 			return -EINVAL;
 		}
+
+		if (ipv6_key->ipv6_label & htonl(0xFFF00000)) {
+			OVS_NLERR("IPv6 flow label %x is out of range (max=%x).\n",
+				  ntohl(ipv6_key->ipv6_label), (1 << 20) - 1);
+			return -EINVAL;
+		}
+
 		SW_FLOW_KEY_PUT(match, ipv6.label,
 				ipv6_key->ipv6_label, is_mask);
 		SW_FLOW_KEY_PUT(match, ip.proto,
-- 
1.9.3
