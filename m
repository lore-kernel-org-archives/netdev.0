From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/6] sfc: Add parentheses around use of bitfield
 macro arguments
Date: Tue, 2 Oct 2012 02:27:32 +0100
Message-ID: <1349141252.2577.75.camel@bwh-desktop.uk.solarflarecom.com>
References: <1349141144.2577.73.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17165 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752282Ab2JBB1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 21:27:36 -0400
In-Reply-To: <1349141144.2577.73.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/bitfield.h |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sfc/bitfield.h b/drivers/net/ethernet/sfc/bitfield.h
index b26a954..5400a33 100644
--- a/drivers/net/ethernet/sfc/bitfield.h
+++ b/drivers/net/ethernet/sfc/bitfield.h
@@ -120,10 +120,10 @@ typedef union efx_oword {
  * [0,high-low), with garbage in bits [high-low+1,...).
  */
 #define EFX_EXTRACT_NATIVE(native_element, min, max, low, high)		\
-	(((low > max) || (high < min)) ? 0 :				\
-	 ((low > min) ?							\
-	  ((native_element) >> (low - min)) :				\
-	  ((native_element) << (min - low))))
+	((low) > (max) || (high) < (min) ? 0 :				\
+	 (low) > (min) ?						\
+	 (native_element) >> ((low) - (min)) :				\
+	 (native_element) << ((min) - (low)))
 
 /*
  * Extract bit field portion [low,high) from the 64-bit little-endian
@@ -142,27 +142,27 @@ typedef union efx_oword {
 #define EFX_EXTRACT_OWORD64(oword, low, high)				\
 	((EFX_EXTRACT64((oword).u64[0], 0, 63, low, high) |		\
 	  EFX_EXTRACT64((oword).u64[1], 64, 127, low, high)) &		\
-	 EFX_MASK64(high + 1 - low))
+	 EFX_MASK64((high) + 1 - (low)))
 
 #define EFX_EXTRACT_QWORD64(qword, low, high)				\
 	(EFX_EXTRACT64((qword).u64[0], 0, 63, low, high) &		\
-	 EFX_MASK64(high + 1 - low))
+	 EFX_MASK64((high) + 1 - (low)))
 
 #define EFX_EXTRACT_OWORD32(oword, low, high)				\
 	((EFX_EXTRACT32((oword).u32[0], 0, 31, low, high) |		\
 	  EFX_EXTRACT32((oword).u32[1], 32, 63, low, high) |		\
 	  EFX_EXTRACT32((oword).u32[2], 64, 95, low, high) |		\
 	  EFX_EXTRACT32((oword).u32[3], 96, 127, low, high)) &		\
-	 EFX_MASK32(high + 1 - low))
+	 EFX_MASK32((high) + 1 - (low)))
 
 #define EFX_EXTRACT_QWORD32(qword, low, high)				\
 	((EFX_EXTRACT32((qword).u32[0], 0, 31, low, high) |		\
 	  EFX_EXTRACT32((qword).u32[1], 32, 63, low, high)) &		\
-	 EFX_MASK32(high + 1 - low))
+	 EFX_MASK32((high) + 1 - (low)))
 
 #define EFX_EXTRACT_DWORD(dword, low, high)			\
 	(EFX_EXTRACT32((dword).u32[0], 0, 31, low, high) &	\
-	 EFX_MASK32(high + 1 - low))
+	 EFX_MASK32((high) + 1 - (low)))
 
 #define EFX_OWORD_FIELD64(oword, field)				\
 	EFX_EXTRACT_OWORD64(oword, EFX_LOW_BIT(field),		\
@@ -442,10 +442,10 @@ typedef union efx_oword {
 	cpu_to_le32(EFX_INSERT_NATIVE(min, max, low, high, value))
 
 #define EFX_INPLACE_MASK64(min, max, low, high)				\
-	EFX_INSERT64(min, max, low, high, EFX_MASK64(high + 1 - low))
+	EFX_INSERT64(min, max, low, high, EFX_MASK64((high) + 1 - (low)))
 
 #define EFX_INPLACE_MASK32(min, max, low, high)				\
-	EFX_INSERT32(min, max, low, high, EFX_MASK32(high + 1 - low))
+	EFX_INSERT32(min, max, low, high, EFX_MASK32((high) + 1 - (low)))
 
 #define EFX_SET_OWORD64(oword, low, high, value) do {			\
 	(oword).u64[0] = (((oword).u64[0]				\
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
