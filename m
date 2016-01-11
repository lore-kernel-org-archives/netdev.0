From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] net: Fix typo in netdev_intersect_features
Date: Mon, 11 Jan 2016 10:19:10 -0800
Message-ID: <1452536350-432426-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jackm@dev.mellanox.co.il>, <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:13799 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758062AbcAKSUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 13:20:20 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.15.0.59/8.15.0.59) with SMTP id u0BI8iAS010797
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 10:20:19 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 20cdy08wbp-8
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 10:20:19 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 d087eb46b88f11e58b1e24be0593f280-f59fa1f0 for <netdev@vger.kernel.org>;	Mon,
 11 Jan 2016 10:19:12 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Obviously need to 'or in NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM.

Fixes: c8cd0989bd151f ("net: Eliminate NETIF_F_GEN_CSUM and NETIF_F_V[46]_CSUM")
Reported-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/netdevice.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8d8e5ca..a951274 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3871,9 +3871,9 @@ static inline netdev_features_t netdev_intersect_features(netdev_features_t f1,
 {
 	if ((f1 ^ f2) & NETIF_F_HW_CSUM) {
 		if (f1 & NETIF_F_HW_CSUM)
-			f1 |= (NETIF_F_IP_CSUM|NETIF_F_IP_CSUM);
+			f1 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
 		else
-			f2 |= (NETIF_F_IP_CSUM|NETIF_F_IP_CSUM);
+			f2 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
 	}
 
 	return f1 & f2;
-- 
2.4.6
