From: Shweta Choudaha <schoudah@brocade.com>
Subject: [PATCH net] ip6gre: Allow live link address change
Date: Wed, 8 Jun 2016 20:15:43 +0100
Message-ID: <1465413343-1405-1-git-send-email-schoudah@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:32426 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423237AbcFHTQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 15:16:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ip6 GRE tap device should not be forced to down state to change
the mac address and should allow live address change for tap device
similar to ipv4 gre.

Signed-off-by: Shweta Choudaha <schoudah@brocade.com>
---
 net/ipv6/ip6_gre.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index f4ac284..fdc9de2 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1256,6 +1256,8 @@ static int ip6gre_tap_init(struct net_device *dev)
 	if (ret)
 		return ret;
 
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+
 	tunnel = netdev_priv(dev);
 
 	ip6gre_tnl_link_config(tunnel, 1);
@@ -1289,6 +1291,7 @@ static void ip6gre_tap_setup(struct net_device *dev)
 
 	dev->features |= NETIF_F_NETNS_LOCAL;
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 }
 
 static bool ip6gre_netlink_encap_parms(struct nlattr *data[],
-- 
2.1.4
