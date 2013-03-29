From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 1/6] openvswitch: Specify the minimal length of OVS_PACKET_ATTR_PACKET in the policy
Date: Fri, 29 Mar 2013 14:46:47 +0100
Message-ID: <7b87af0900cd2061b644a361827a48ac99c98ed4.1364563346.git.tgraf@suug.ch>
References: <cover.1364563346.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:52005
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755956Ab3C2Nq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 09:46:58 -0400
In-Reply-To: <cover.1364563346.git.tgraf@suug.ch>
In-Reply-To: <cover.1364563346.git.tgraf@suug.ch>
References: <cover.1364563346.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Specifying the minimal length in the policy makes it reuseable
and documents the interface.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/datapath.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 8759265..5b58d16 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -662,8 +662,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 
 	err = -EINVAL;
 	if (!a[OVS_PACKET_ATTR_PACKET] || !a[OVS_PACKET_ATTR_KEY] ||
-	    !a[OVS_PACKET_ATTR_ACTIONS] ||
-	    nla_len(a[OVS_PACKET_ATTR_PACKET]) < ETH_HLEN)
+	    !a[OVS_PACKET_ATTR_ACTIONS])
 		goto err;
 
 	len = nla_len(a[OVS_PACKET_ATTR_PACKET]);
@@ -744,7 +743,7 @@ err:
 }
 
 static const struct nla_policy packet_policy[OVS_PACKET_ATTR_MAX + 1] = {
-	[OVS_PACKET_ATTR_PACKET] = { .type = NLA_UNSPEC },
+	[OVS_PACKET_ATTR_PACKET] = { .len = ETH_HLEN },
 	[OVS_PACKET_ATTR_KEY] = { .type = NLA_NESTED },
 	[OVS_PACKET_ATTR_ACTIONS] = { .type = NLA_NESTED },
 };
-- 
1.7.11.7
