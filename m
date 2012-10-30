From: Vincent Bernat <bernat@luffy.cx>
Subject: [PATCH] vxlan: allow a user to set TTL value
Date: Tue, 30 Oct 2012 21:27:16 +0100
Message-ID: <1351628836-23094-1-git-send-email-bernat@luffy.cx>
Cc: Vincent Bernat <bernat@luffy.cx>
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftmxout01ba.infra.b2.fti.net ([193.252.121.124]:46613 "EHLO
	ftmxout01ba.infra.b2.fti.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750961Ab2J3UxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 16:53:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"ip link add ... type vxlan ... ttl X" allows a user to set the TTL
used by a VXLAN for encapsulation. The provided value was ignored by
vxlan module and the default value of 1 was used when encapsulating
multicast packets.

Signed-off-by: Vincent Bernat <bernat@luffy.cx>
---
 drivers/net/vxlan.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 607976c..030559d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1107,6 +1107,9 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	if (data[IFLA_VXLAN_TOS])
 		vxlan->tos  = nla_get_u8(data[IFLA_VXLAN_TOS]);
 
+	if (data[IFLA_VXLAN_TTL])
+		vxlan->ttl = nla_get_u8(data[IFLA_VXLAN_TTL]);
+
 	if (!data[IFLA_VXLAN_LEARNING] || nla_get_u8(data[IFLA_VXLAN_LEARNING]))
 		vxlan->learn = true;
 
-- 
1.7.10.4
