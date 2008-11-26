From: Patrick McHardy <kaber@trash.net>
Subject: macvlan: don't broadcast PAUSE frames to macvlan devices
Date: Wed, 26 Nov 2008 16:53:06 +0100
Message-ID: <492D70E2.2040105@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060509010605090108070504"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60991 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbYKZPxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 10:53:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060509010605090108070504
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------060509010605090108070504
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 19e521e49972878b133cb1449a5ac38052d36f3d
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Nov 26 11:48:09 2008 +0100

    macvlan: don't broadcast PAUSE frames to macvlan devices
    
    PAUSE frames are only relevant for the real device, broadcasting them
    to all macvlan devices can cause a significant load increase.
    
    Reported-by: Ben Greear <greearb@candelatech.com>
    Tested-by: Ben Greear <greearb@candelatech.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index e887921..7e24b50 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -70,6 +70,9 @@ static void macvlan_broadcast(struct sk_buff *skb,
 	struct sk_buff *nskb;
 	unsigned int i;
 
+	if (skb->protocol == htons(ETH_P_PAUSE))
+		return;
+
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++) {
 		hlist_for_each_entry_rcu(vlan, n, &port->vlan_hash[i], hlist) {
 			dev = vlan->dev;

--------------060509010605090108070504--
