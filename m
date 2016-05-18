From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v7 net-next 13/16] ipv6: Set features for IPv6 tunnels
Date: Wed, 18 May 2016 09:06:21 -0700
Message-ID: <1463587584-2315623-14-git-send-email-tom@herbertland.com>
References: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:16215 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932780AbcERQGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 12:06:52 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u4IG436J016941
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:06:52 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 22wypbbc14-8
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:06:51 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 85364f1a1d1211e689100002c99293a0-3fbf2c50 for <netdev@vger.kernel.org>;	Wed,
 18 May 2016 09:06:46 -0700
In-Reply-To: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to set dev features, use same values that are used in GREv6.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_tunnel.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 74b35e4..cabf492 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1640,6 +1640,11 @@ static const struct net_device_ops ip6_tnl_netdev_ops = {
 	.ndo_get_iflink = ip6_tnl_get_iflink,
 };
 
+#define IPXIPX_FEATURES (NETIF_F_SG |		\
+			 NETIF_F_FRAGLIST |	\
+			 NETIF_F_HIGHDMA |	\
+			 NETIF_F_GSO_SOFTWARE |	\
+			 NETIF_F_HW_CSUM)
 
 /**
  * ip6_tnl_dev_setup - setup virtual tunnel device
@@ -1659,6 +1664,10 @@ static void ip6_tnl_dev_setup(struct net_device *dev)
 	dev->addr_len = sizeof(struct in6_addr);
 	dev->features |= NETIF_F_LLTX;
 	netif_keep_dst(dev);
+
+	dev->features		|= IPXIPX_FEATURES;
+	dev->hw_features	|= IPXIPX_FEATURES;
+
 	/* This perm addr will be used as interface identifier by IPv6 */
 	dev->addr_assign_type = NET_ADDR_RANDOM;
 	eth_random_addr(dev->perm_addr);
-- 
2.8.0.rc2
