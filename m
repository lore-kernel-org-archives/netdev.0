From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH] netdev_features: Add NETIF_F_TSO_MANGLEID to
 NETIF_F_ALL_TSO
Date: Thu, 14 Apr 2016 17:04:34 -0400
Message-ID: <20160414210434.14117.52071.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: jesse@kernel.org, netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35250 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758AbcDNVEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 17:04:41 -0400
Received: by mail-pf0-f174.google.com with SMTP id n1so49504658pfn.2
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 14:04:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I realized that when I added NETIF_F_TSO_MANGLEID as a TSO type I forgot to
add it to NETIF_F_ALL_TSO.  This patch corrects that so the flag will be
included correctly.

The result should be minor as it was only used by a few drivers and in a
few specific cases such as when NETIF_F_SG was not supported on a device so
the TSO flags were cleared.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 include/linux/netdev_features.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 9fc79df0e561..15eb0b12fff9 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -164,7 +164,8 @@ enum {
 #define NETIF_F_CSUM_MASK	(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | \
 				 NETIF_F_HW_CSUM)
 
-#define NETIF_F_ALL_TSO 	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
+#define NETIF_F_ALL_TSO 	(NETIF_F_TSO | NETIF_F_TSO6 | \
+				 NETIF_F_TSO_ECN | NETIF_F_TSO_MANGLEID)
 
 #define NETIF_F_ALL_FCOE	(NETIF_F_FCOE_CRC | NETIF_F_FCOE_MTU | \
 				 NETIF_F_FSO)
