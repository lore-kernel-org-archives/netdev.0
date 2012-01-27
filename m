From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 30/32] sfc: Make all MAC statistics consistently 64
 bits wide
Date: Fri, 27 Jan 2012 20:53:46 +0000
Message-ID: <1327697626.2503.38.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:63882 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752835Ab2A0Uxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:53:49 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we use type u64 for byte counts, which can very quickly
exceed 2^32, and unsigned long for packet counts, which do not.  But
it can still take only 20-something minutes to send or receive 2^32
packets, and not all tools properly handle overflow even if they
sample more often than this.

The MAC statistics are all updated synchronously, so it costs very
little to make them all 64-bit regardless of native word size.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c    |  117 +++++++++++++++------------------
 drivers/net/ethernet/sfc/net_driver.h |  110 +++++++++++++++---------------
 2 files changed, 109 insertions(+), 118 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index ba90116..f887f65 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -52,11 +52,6 @@ static u64 efx_get_uint_stat(void *field)
 	return *(unsigned int *)field;
 }
 
-static u64 efx_get_ulong_stat(void *field)
-{
-	return *(unsigned long *)field;
-}
-
 static u64 efx_get_u64_stat(void *field)
 {
 	return *(u64 *) field;
@@ -67,10 +62,6 @@ static u64 efx_get_atomic_stat(void *field)
 	return atomic_read((atomic_t *) field);
 }
 
-#define EFX_ETHTOOL_ULONG_MAC_STAT(field)			\
-	EFX_ETHTOOL_STAT(field, mac_stats, field,		\
-			  unsigned long, efx_get_ulong_stat)
-
 #define EFX_ETHTOOL_U64_MAC_STAT(field)				\
 	EFX_ETHTOOL_STAT(field, mac_stats, field,		\
 			  u64, efx_get_u64_stat)
@@ -95,32 +86,32 @@ static const struct efx_ethtool_stat efx_ethtool_stats[] = {
 	EFX_ETHTOOL_U64_MAC_STAT(tx_bytes),
 	EFX_ETHTOOL_U64_MAC_STAT(tx_good_bytes),
 	EFX_ETHTOOL_U64_MAC_STAT(tx_bad_bytes),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_packets),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_bad),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_pause),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_control),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_unicast),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_multicast),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_broadcast),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_lt64),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_64),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_65_to_127),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_128_to_255),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_256_to_511),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_512_to_1023),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_1024_to_15xx),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_15xx_to_jumbo),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_gtjumbo),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_collision),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_single_collision),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_multiple_collision),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_excessive_collision),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_deferred),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_late_collision),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_excessive_deferred),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_non_tcpudp),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_mac_src_error),
-	EFX_ETHTOOL_ULONG_MAC_STAT(tx_ip_src_error),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_packets),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_bad),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_pause),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_control),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_unicast),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_multicast),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_broadcast),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_lt64),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_64),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_65_to_127),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_128_to_255),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_256_to_511),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_512_to_1023),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_1024_to_15xx),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_15xx_to_jumbo),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_gtjumbo),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_collision),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_single_collision),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_multiple_collision),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_excessive_collision),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_deferred),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_late_collision),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_excessive_deferred),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_non_tcpudp),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_mac_src_error),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_ip_src_error),
 	EFX_ETHTOOL_UINT_TXQ_STAT(tso_bursts),
 	EFX_ETHTOOL_UINT_TXQ_STAT(tso_long_headers),
 	EFX_ETHTOOL_UINT_TXQ_STAT(tso_packets),
@@ -128,34 +119,34 @@ static const struct efx_ethtool_stat efx_ethtool_stats[] = {
 	EFX_ETHTOOL_U64_MAC_STAT(rx_bytes),
 	EFX_ETHTOOL_U64_MAC_STAT(rx_good_bytes),
 	EFX_ETHTOOL_U64_MAC_STAT(rx_bad_bytes),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_packets),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_good),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_bad),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_pause),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_control),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_unicast),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_multicast),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_broadcast),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_lt64),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_64),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_65_to_127),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_128_to_255),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_256_to_511),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_512_to_1023),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_1024_to_15xx),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_15xx_to_jumbo),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_gtjumbo),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_bad_lt64),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_bad_64_to_15xx),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_bad_15xx_to_jumbo),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_bad_gtjumbo),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_overflow),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_missed),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_false_carrier),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_symbol_error),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_align_error),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_length_error),
-	EFX_ETHTOOL_ULONG_MAC_STAT(rx_internal_error),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_packets),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_good),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_bad),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_pause),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_control),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_unicast),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_multicast),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_broadcast),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_lt64),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_64),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_65_to_127),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_128_to_255),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_256_to_511),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_512_to_1023),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_1024_to_15xx),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_15xx_to_jumbo),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_gtjumbo),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_bad_lt64),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_bad_64_to_15xx),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_bad_15xx_to_jumbo),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_bad_gtjumbo),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_overflow),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_missed),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_false_carrier),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_symbol_error),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_align_error),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_length_error),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_internal_error),
 	EFX_ETHTOOL_UINT_NIC_STAT(rx_nodesc_drop_cnt),
 	EFX_ETHTOOL_ATOMIC_NIC_ERROR_STAT(rx_reset),
 	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_tobe_disc),
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 310c50f..c20483e 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -538,64 +538,64 @@ struct efx_mac_stats {
 	u64 tx_bytes;
 	u64 tx_good_bytes;
 	u64 tx_bad_bytes;
-	unsigned long tx_packets;
-	unsigned long tx_bad;
-	unsigned long tx_pause;
-	unsigned long tx_control;
-	unsigned long tx_unicast;
-	unsigned long tx_multicast;
-	unsigned long tx_broadcast;
-	unsigned long tx_lt64;
-	unsigned long tx_64;
-	unsigned long tx_65_to_127;
-	unsigned long tx_128_to_255;
-	unsigned long tx_256_to_511;
-	unsigned long tx_512_to_1023;
-	unsigned long tx_1024_to_15xx;
-	unsigned long tx_15xx_to_jumbo;
-	unsigned long tx_gtjumbo;
-	unsigned long tx_collision;
-	unsigned long tx_single_collision;
-	unsigned long tx_multiple_collision;
-	unsigned long tx_excessive_collision;
-	unsigned long tx_deferred;
-	unsigned long tx_late_collision;
-	unsigned long tx_excessive_deferred;
-	unsigned long tx_non_tcpudp;
-	unsigned long tx_mac_src_error;
-	unsigned long tx_ip_src_error;
+	u64 tx_packets;
+	u64 tx_bad;
+	u64 tx_pause;
+	u64 tx_control;
+	u64 tx_unicast;
+	u64 tx_multicast;
+	u64 tx_broadcast;
+	u64 tx_lt64;
+	u64 tx_64;
+	u64 tx_65_to_127;
+	u64 tx_128_to_255;
+	u64 tx_256_to_511;
+	u64 tx_512_to_1023;
+	u64 tx_1024_to_15xx;
+	u64 tx_15xx_to_jumbo;
+	u64 tx_gtjumbo;
+	u64 tx_collision;
+	u64 tx_single_collision;
+	u64 tx_multiple_collision;
+	u64 tx_excessive_collision;
+	u64 tx_deferred;
+	u64 tx_late_collision;
+	u64 tx_excessive_deferred;
+	u64 tx_non_tcpudp;
+	u64 tx_mac_src_error;
+	u64 tx_ip_src_error;
 	u64 rx_bytes;
 	u64 rx_good_bytes;
 	u64 rx_bad_bytes;
-	unsigned long rx_packets;
-	unsigned long rx_good;
-	unsigned long rx_bad;
-	unsigned long rx_pause;
-	unsigned long rx_control;
-	unsigned long rx_unicast;
-	unsigned long rx_multicast;
-	unsigned long rx_broadcast;
-	unsigned long rx_lt64;
-	unsigned long rx_64;
-	unsigned long rx_65_to_127;
-	unsigned long rx_128_to_255;
-	unsigned long rx_256_to_511;
-	unsigned long rx_512_to_1023;
-	unsigned long rx_1024_to_15xx;
-	unsigned long rx_15xx_to_jumbo;
-	unsigned long rx_gtjumbo;
-	unsigned long rx_bad_lt64;
-	unsigned long rx_bad_64_to_15xx;
-	unsigned long rx_bad_15xx_to_jumbo;
-	unsigned long rx_bad_gtjumbo;
-	unsigned long rx_overflow;
-	unsigned long rx_missed;
-	unsigned long rx_false_carrier;
-	unsigned long rx_symbol_error;
-	unsigned long rx_align_error;
-	unsigned long rx_length_error;
-	unsigned long rx_internal_error;
-	unsigned long rx_good_lt64;
+	u64 rx_packets;
+	u64 rx_good;
+	u64 rx_bad;
+	u64 rx_pause;
+	u64 rx_control;
+	u64 rx_unicast;
+	u64 rx_multicast;
+	u64 rx_broadcast;
+	u64 rx_lt64;
+	u64 rx_64;
+	u64 rx_65_to_127;
+	u64 rx_128_to_255;
+	u64 rx_256_to_511;
+	u64 rx_512_to_1023;
+	u64 rx_1024_to_15xx;
+	u64 rx_15xx_to_jumbo;
+	u64 rx_gtjumbo;
+	u64 rx_bad_lt64;
+	u64 rx_bad_64_to_15xx;
+	u64 rx_bad_15xx_to_jumbo;
+	u64 rx_bad_gtjumbo;
+	u64 rx_overflow;
+	u64 rx_missed;
+	u64 rx_false_carrier;
+	u64 rx_symbol_error;
+	u64 rx_align_error;
+	u64 rx_length_error;
+	u64 rx_internal_error;
+	u64 rx_good_lt64;
 };
 
 /* Number of bits used in a multicast filter hash address */
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
