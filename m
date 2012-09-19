From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 05/11] sfc: Fix maximum array sizes for various
 MCDI commands
Date: Wed, 19 Sep 2012 20:16:36 +0100
Message-ID: <1348082196.2636.20.camel@bwh-desktop.uk.solarflarecom.com>
References: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20175 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756958Ab2ISTQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 15:16:39 -0400
In-Reply-To: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The maximum array sizes have been calculated on the basis of a maximum
SDU size of 255 bytes, whereas the actual maximum is 252 bytes.
Constructing a larger SDU will result in a BUG_ON in efx_mcdi_copyin.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_pcol.h |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index db4beed..5038932 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -491,12 +491,12 @@
 
 /* MC_CMD_GET_FPGAREG_OUT msgresponse */
 #define    MC_CMD_GET_FPGAREG_OUT_LENMIN 1
-#define    MC_CMD_GET_FPGAREG_OUT_LENMAX 255
+#define    MC_CMD_GET_FPGAREG_OUT_LENMAX 252
 #define    MC_CMD_GET_FPGAREG_OUT_LEN(num) (0+1*(num))
 #define       MC_CMD_GET_FPGAREG_OUT_BUFFER_OFST 0
 #define       MC_CMD_GET_FPGAREG_OUT_BUFFER_LEN 1
 #define       MC_CMD_GET_FPGAREG_OUT_BUFFER_MINNUM 1
-#define       MC_CMD_GET_FPGAREG_OUT_BUFFER_MAXNUM 255
+#define       MC_CMD_GET_FPGAREG_OUT_BUFFER_MAXNUM 252
 

 /***********************************/
@@ -507,13 +507,13 @@
 
 /* MC_CMD_PUT_FPGAREG_IN msgrequest */
 #define    MC_CMD_PUT_FPGAREG_IN_LENMIN 5
-#define    MC_CMD_PUT_FPGAREG_IN_LENMAX 255
+#define    MC_CMD_PUT_FPGAREG_IN_LENMAX 252
 #define    MC_CMD_PUT_FPGAREG_IN_LEN(num) (4+1*(num))
 #define       MC_CMD_PUT_FPGAREG_IN_ADDR_OFST 0
 #define       MC_CMD_PUT_FPGAREG_IN_BUFFER_OFST 4
 #define       MC_CMD_PUT_FPGAREG_IN_BUFFER_LEN 1
 #define       MC_CMD_PUT_FPGAREG_IN_BUFFER_MINNUM 1
-#define       MC_CMD_PUT_FPGAREG_IN_BUFFER_MAXNUM 251
+#define       MC_CMD_PUT_FPGAREG_IN_BUFFER_MAXNUM 248
 
 /* MC_CMD_PUT_FPGAREG_OUT msgresponse */
 #define    MC_CMD_PUT_FPGAREG_OUT_LEN 0
@@ -560,7 +560,7 @@
 
 /* MC_CMD_PTP_IN_TRANSMIT msgrequest */
 #define    MC_CMD_PTP_IN_TRANSMIT_LENMIN 13
-#define    MC_CMD_PTP_IN_TRANSMIT_LENMAX 255
+#define    MC_CMD_PTP_IN_TRANSMIT_LENMAX 252
 #define    MC_CMD_PTP_IN_TRANSMIT_LEN(num) (12+1*(num))
 /*            MC_CMD_PTP_IN_CMD_OFST 0 */
 /*            MC_CMD_PTP_IN_PERIPH_ID_OFST 4 */
@@ -568,7 +568,7 @@
 #define       MC_CMD_PTP_IN_TRANSMIT_PACKET_OFST 12
 #define       MC_CMD_PTP_IN_TRANSMIT_PACKET_LEN 1
 #define       MC_CMD_PTP_IN_TRANSMIT_PACKET_MINNUM 1
-#define       MC_CMD_PTP_IN_TRANSMIT_PACKET_MAXNUM 243
+#define       MC_CMD_PTP_IN_TRANSMIT_PACKET_MAXNUM 240
 
 /* MC_CMD_PTP_IN_READ_NIC_TIME msgrequest */
 #define    MC_CMD_PTP_IN_READ_NIC_TIME_LEN 8
@@ -1145,7 +1145,7 @@
 
 /* MC_CMD_PUTS_IN msgrequest */
 #define    MC_CMD_PUTS_IN_LENMIN 13
-#define    MC_CMD_PUTS_IN_LENMAX 255
+#define    MC_CMD_PUTS_IN_LENMAX 252
 #define    MC_CMD_PUTS_IN_LEN(num) (12+1*(num))
 #define       MC_CMD_PUTS_IN_DEST_OFST 0
 #define        MC_CMD_PUTS_IN_UART_LBN 0
@@ -1157,7 +1157,7 @@
 #define       MC_CMD_PUTS_IN_STRING_OFST 12
 #define       MC_CMD_PUTS_IN_STRING_LEN 1
 #define       MC_CMD_PUTS_IN_STRING_MINNUM 1
-#define       MC_CMD_PUTS_IN_STRING_MAXNUM 243
+#define       MC_CMD_PUTS_IN_STRING_MAXNUM 240
 
 /* MC_CMD_PUTS_OUT msgresponse */
 #define    MC_CMD_PUTS_OUT_LEN 0
@@ -1947,12 +1947,12 @@
 
 /* MC_CMD_NVRAM_READ_OUT msgresponse */
 #define    MC_CMD_NVRAM_READ_OUT_LENMIN 1
-#define    MC_CMD_NVRAM_READ_OUT_LENMAX 255
+#define    MC_CMD_NVRAM_READ_OUT_LENMAX 252
 #define    MC_CMD_NVRAM_READ_OUT_LEN(num) (0+1*(num))
 #define       MC_CMD_NVRAM_READ_OUT_READ_BUFFER_OFST 0
 #define       MC_CMD_NVRAM_READ_OUT_READ_BUFFER_LEN 1
 #define       MC_CMD_NVRAM_READ_OUT_READ_BUFFER_MINNUM 1
-#define       MC_CMD_NVRAM_READ_OUT_READ_BUFFER_MAXNUM 255
+#define       MC_CMD_NVRAM_READ_OUT_READ_BUFFER_MAXNUM 252
 

 /***********************************/
@@ -1963,7 +1963,7 @@
 
 /* MC_CMD_NVRAM_WRITE_IN msgrequest */
 #define    MC_CMD_NVRAM_WRITE_IN_LENMIN 13
-#define    MC_CMD_NVRAM_WRITE_IN_LENMAX 255
+#define    MC_CMD_NVRAM_WRITE_IN_LENMAX 252
 #define    MC_CMD_NVRAM_WRITE_IN_LEN(num) (12+1*(num))
 #define       MC_CMD_NVRAM_WRITE_IN_TYPE_OFST 0
 /*            Enum values, see field(s): */
@@ -1973,7 +1973,7 @@
 #define       MC_CMD_NVRAM_WRITE_IN_WRITE_BUFFER_OFST 12
 #define       MC_CMD_NVRAM_WRITE_IN_WRITE_BUFFER_LEN 1
 #define       MC_CMD_NVRAM_WRITE_IN_WRITE_BUFFER_MINNUM 1
-#define       MC_CMD_NVRAM_WRITE_IN_WRITE_BUFFER_MAXNUM 243
+#define       MC_CMD_NVRAM_WRITE_IN_WRITE_BUFFER_MAXNUM 240
 
 /* MC_CMD_NVRAM_WRITE_OUT msgresponse */
 #define    MC_CMD_NVRAM_WRITE_OUT_LEN 0
@@ -2305,13 +2305,13 @@
 
 /* MC_CMD_GET_PHY_MEDIA_INFO_OUT msgresponse */
 #define    MC_CMD_GET_PHY_MEDIA_INFO_OUT_LENMIN 5
-#define    MC_CMD_GET_PHY_MEDIA_INFO_OUT_LENMAX 255
+#define    MC_CMD_GET_PHY_MEDIA_INFO_OUT_LENMAX 252
 #define    MC_CMD_GET_PHY_MEDIA_INFO_OUT_LEN(num) (4+1*(num))
 #define       MC_CMD_GET_PHY_MEDIA_INFO_OUT_DATALEN_OFST 0
 #define       MC_CMD_GET_PHY_MEDIA_INFO_OUT_DATA_OFST 4
 #define       MC_CMD_GET_PHY_MEDIA_INFO_OUT_DATA_LEN 1
 #define       MC_CMD_GET_PHY_MEDIA_INFO_OUT_DATA_MINNUM 1
-#define       MC_CMD_GET_PHY_MEDIA_INFO_OUT_DATA_MAXNUM 251
+#define       MC_CMD_GET_PHY_MEDIA_INFO_OUT_DATA_MAXNUM 248
 

 /***********************************/
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
