From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/8] ethtool: Add Ethernet MAC-level
 filtering/steering
Date: Mon, 20 Sep 2010 19:42:08 +0100
Message-ID: <1285008128.2282.105.camel@achroite.uk.solarflarecom.com>
References: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:7142 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262Ab0ITSmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 14:42:11 -0400
In-Reply-To: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 3350870..8a3338c 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -14,6 +14,7 @@
 #define _LINUX_ETHTOOL_H
 
 #include <linux/types.h>
+#include <linux/if_ether.h>
 
 /* This should work for both 32 and 64 bit userland. */
 struct ethtool_cmd {
@@ -391,6 +392,7 @@ struct ethtool_rx_flow_spec {
 		struct ethtool_ah_espip4_spec		ah_ip4_spec;
 		struct ethtool_ah_espip4_spec		esp_ip4_spec;
 		struct ethtool_usrip4_spec		usr_ip4_spec;
+		struct ethhdr				ether_spec;
 		__u8					hdata[72];
 	} h_u, m_u;
 	__u64		ring_cookie;
@@ -483,6 +485,7 @@ struct ethtool_rx_ntuple_flow_spec {
 		struct ethtool_ah_espip4_spec		ah_ip4_spec;
 		struct ethtool_ah_espip4_spec		esp_ip4_spec;
 		struct ethtool_usrip4_spec		usr_ip4_spec;
+		struct ethhdr				ether_spec;
 		__u8					hdata[72];
 	} h_u, m_u;
 
@@ -841,7 +844,7 @@ struct ethtool_ops {
 #define WAKE_MAGIC		(1 << 5)
 #define WAKE_MAGICSECURE	(1 << 6) /* only meaningful if WAKE_MAGIC */
 
-/* L3-L4 network traffic flow types */
+/* L2-L4 network traffic flow types */
 #define	TCP_V4_FLOW	0x01	/* hash or spec (tcp_ip4_spec) */
 #define	UDP_V4_FLOW	0x02	/* hash or spec (udp_ip4_spec) */
 #define	SCTP_V4_FLOW	0x03	/* hash or spec (sctp_ip4_spec) */
@@ -857,6 +860,7 @@ struct ethtool_ops {
 #define	IP_USER_FLOW	0x0d	/* spec only (usr_ip4_spec) */
 #define	IPV4_FLOW	0x10	/* hash only */
 #define	IPV6_FLOW	0x11	/* hash only */
+#define	ETHER_FLOW	0x12	/* spec only (ether_spec) */
 
 /* L3-L4 network traffic flow hash options */
 #define	RXH_L2DA	(1 << 1)
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

