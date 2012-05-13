From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] openvswitch: checking wrong variable in
 queue_userspace_packet()
Date: Sun, 13 May 2012 21:44:18 +0300
Message-ID: <20120513184418.GB16541@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, dev@openvswitch.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:34004 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256Ab2EMSod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 May 2012 14:44:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"skb" is non-NULL here, for example we dereference it in skb_clone().
The intent was to test "nskb" which was just set.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index fe28562..2c74daa 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -321,7 +321,7 @@ static int queue_userspace_packet(int dp_ifindex, struct sk_buff *skb,
 			return -ENOMEM;
 
 		nskb = __vlan_put_tag(nskb, vlan_tx_tag_get(nskb));
-		if (!skb)
+		if (!nskb)
 			return -ENOMEM;
 
 		nskb->vlan_tci = 0;
