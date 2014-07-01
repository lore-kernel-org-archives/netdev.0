From: Zhao Qiang <B45475@freescale.com>
Subject: [PATCH] powerpc/ucc_geth: deal with a compile warning
Date: Tue, 1 Jul 2014 09:21:34 +0800
Message-ID: <1404177694-5547-1-git-send-email-B45475@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zhao Qiang <B45475@freescale.com>
To: <linuxppc-dev@lists.ozlabs.org>, <leoli@freescale.com>,
	<netdev@vger.kernel.org>, <B07421@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0142.outbound.protection.outlook.com ([207.46.163.142]:25308
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752374AbaGABZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2014 21:25:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

deal with a compile warning: comparison between
'enum qe_fltr_largest_external_tbl_lookup_key_size'
and 'enum qe_fltr_tbl_lookup_key_size'

the code:
	"if (ug_info->largestexternallookupkeysize ==
	     QE_FLTR_TABLE_LOOKUP_KEY_SIZE_8_BYTES)"
is warned because different enum, so modify it.

	"enum qe_fltr_largest_external_tbl_lookup_key_size
	             largestexternallookupkeysize;

	enum qe_fltr_tbl_lookup_key_size {
		 QE_FLTR_TABLE_LOOKUP_KEY_SIZE_8_BYTES
			 = 0x3f,         /* LookupKey parsed by the Generate LookupKey
					    CMD is truncated to 8 bytes */
		 QE_FLTR_TABLE_LOOKUP_KEY_SIZE_16_BYTES
			 = 0x5f,         /* LookupKey parsed by the Generate LookupKey
					    CMD is truncated to 16 bytes */
	 };

	 /* QE FLTR extended filtering Largest External Table Lookup Key Size */
	 enum qe_fltr_largest_external_tbl_lookup_key_size {
		 QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_NONE
			 = 0x0,/* not used */
		 QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_8_BYTES
			 = QE_FLTR_TABLE_LOOKUP_KEY_SIZE_8_BYTES,        /* 8 bytes */
		 QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_16_BYTES
			 = QE_FLTR_TABLE_LOOKUP_KEY_SIZE_16_BYTES,       /* 16 bytes */
	 };"

Signed-off-by: Zhao Qiang <B45475@freescale.com>
---
 drivers/net/ethernet/freescale/ucc_geth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index c8299c3..0bf5ba1 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -2993,11 +2993,11 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	if (ug_info->rxExtendedFiltering) {
 		size += THREAD_RX_PRAM_ADDITIONAL_FOR_EXTENDED_FILTERING;
 		if (ug_info->largestexternallookupkeysize ==
-		    QE_FLTR_TABLE_LOOKUP_KEY_SIZE_8_BYTES)
+		    QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_8_BYTES)
 			size +=
 			    THREAD_RX_PRAM_ADDITIONAL_FOR_EXTENDED_FILTERING_8;
 		if (ug_info->largestexternallookupkeysize ==
-		    QE_FLTR_TABLE_LOOKUP_KEY_SIZE_16_BYTES)
+		    QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_16_BYTES)
 			size +=
 			    THREAD_RX_PRAM_ADDITIONAL_FOR_EXTENDED_FILTERING_16;
 	}
-- 
1.8.5
