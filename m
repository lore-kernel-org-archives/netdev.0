From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 01/10] openvswitch: Specify the minimal length of OVS_PACKET_ATTR_PACKET in the policy
Date: Tue, 16 Apr 2013 14:00:10 -0700
Message-ID: <1366146019-9015-2-git-send-email-jesse@nicira.com>
References: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Thomas Graf <tgraf@suug.ch>, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:33011 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965214Ab3DPVAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 17:00:14 -0400
Received: by mail-pa0-f72.google.com with SMTP id bi5so793564pad.11
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 14:00:13 -0700 (PDT)
In-Reply-To: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>

Specifying the minimal length in the policy makes it reuseable
and documents the interface.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/datapath.c |    5 ++---
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
1.7.10.4
