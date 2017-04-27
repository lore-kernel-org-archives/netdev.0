From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH net-next] geneve: fix incorrect setting of UDP checksum flag
Date: Thu, 27 Apr 2017 14:11:53 -0700
Message-ID: <1493327513-23247-1-git-send-email-girish.moodalbail@oracle.com>
Cc: <netdev@vger.kernel.org>, <pshelar@ovn.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:44309 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423095AbdD0VTq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 17:19:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Creating a geneve link with 'udpcsum' set results in a creation of link
for which UDP checksum will NOT be computed on outbound packets, as can
be seen below.

11: gen0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
    link/ether c2:85:27:b6:b4:15 brd ff:ff:ff:ff:ff:ff promiscuity 0
    geneve id 200 remote 192.168.13.1 dstport 6081 noudpcsum

Similarly, creating a link with 'noudpcsum' set results in a creation
of link for which UDP checksum will be computed on outbound packets.

Fixes: 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
---
 drivers/net/geneve.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 7074b40..dec5d56 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1244,7 +1244,7 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 		metadata = true;
 
 	if (data[IFLA_GENEVE_UDP_CSUM] &&
-	    !nla_get_u8(data[IFLA_GENEVE_UDP_CSUM]))
+	    nla_get_u8(data[IFLA_GENEVE_UDP_CSUM]))
 		info.key.tun_flags |= TUNNEL_CSUM;
 
 	if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX] &&
-- 
1.8.3.1
