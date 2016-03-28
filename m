From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] openvswitch: Use proper buffer size in nla_memcpy
Date: Mon, 28 Mar 2016 18:08:59 +0800
Message-ID: <1459159739-51541-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dev@openvswitch.org,
	Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:12218 "EHLO
	cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbcC1KJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 06:09:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the input parameter count, it's better to use the size
of destination buffer size, as nla_memcpy would take into
account the length of the source netlink attribute when
a data is copied from an attribute.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/openvswitch/conntrack.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index dc5eb29..f8a8d43 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -968,7 +968,8 @@ static int parse_nat(const struct nlattr *attr,
 			break;
 
 		case OVS_NAT_ATTR_IP_MIN:
-			nla_memcpy(&info->range.min_addr, a, nla_len(a));
+			nla_memcpy(&info->range.min_addr, a,
+				   sizeof(info->range.min_addr));
 			info->range.flags |= NF_NAT_RANGE_MAP_IPS;
 			break;
 
-- 
1.8.3.1
