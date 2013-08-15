From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v3 1/2] macvtap: include all checksum offloads in TUN_OFFLOAD mask
Date: Thu, 15 Aug 2013 13:02:52 -0400
Message-ID: <1376586173-4242-2-git-send-email-vyasevic@redhat.com>
References: <1376586173-4242-1-git-send-email-vyasevic@redhat.com>
Cc: mst@redhat.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49493 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757471Ab3HORC6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 13:02:58 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7FH2wFU023813
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 15 Aug 2013 13:02:58 -0400
In-Reply-To: <1376586173-4242-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The features of the macvlan are based on the features of lower
device and thus can have checksum featurs other then IFF_F_HW_CSUM
set.  However, TUN_OFFLOAD mask only includes IFF_F_HW_CSUM.  Thus
when performing gso segmentation during macvtap_forward(),
it is possbile to end up with skbs that have ip_summed set
to CHECKSUM_PARTIAL.  This is incorrect when the user
turns off checksum offloading.

Include all possible checksum offload values so that
we'll properly mask them off when performing GSO.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvtap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index b51db2a..8121358 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -65,7 +65,7 @@ static struct cdev macvtap_cdev;
 
 static const struct proto_ops macvtap_socket_ops;
 
-#define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
+#define TUN_OFFLOADS (NETIF_F_ALL_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
 		      NETIF_F_TSO6 | NETIF_F_UFO)
 #define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
 /*
-- 
1.8.1.4
