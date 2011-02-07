From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2] CDC NCM errata updates for cdc.h
Date: Mon,  7 Feb 2011 20:45:09 +0100
Message-ID: <1297107910-18263-1-git-send-email-alexey.orishko@stericsson.com>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	yauheni.kaliuta-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Changes are based on the following documents:
- CDC NCM errata:
http://www.usb.org/developers/devclass_docs/NCM10_012011.zip
- CDC and WMC errata link:
http://www.usb.org/developers/devclass_docs/CDC1.2_WMC1.1_012011.zip

Signed-off-by: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
---
 include/linux/usb/cdc.h |   23 ++++++++++++++++++-----
 1 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/include/linux/usb/cdc.h b/include/linux/usb/cdc.h
index 5e86dc7..81a9279 100644
--- a/include/linux/usb/cdc.h
+++ b/include/linux/usb/cdc.h
@@ -89,7 +89,7 @@ struct usb_cdc_acm_descriptor {
 
 #define USB_CDC_COMM_FEATURE	0x01
 #define USB_CDC_CAP_LINE	0x02
-#define USB_CDC_CAP_BRK	0x04
+#define USB_CDC_CAP_BRK		0x04
 #define USB_CDC_CAP_NOTIFY	0x08
 
 /* "Union Functional Descriptor" from CDC spec 5.2.3.8 */
@@ -271,6 +271,11 @@ struct usb_cdc_notification {
 	__le16	wLength;
 } __attribute__ ((packed));
 
+struct usb_cdc_speed_change {
+	__le32	DLBitRRate;	/* contains the downlink bit rate (IN pipe) */
+	__le32	ULBitRate;	/* contains the uplink bit rate (OUT pipe) */
+} __attribute__ ((packed));
+
 /*-------------------------------------------------------------------------*/
 
 /*
@@ -292,7 +297,7 @@ struct usb_cdc_ncm_ntb_parameters {
 	__le16	wNdpOutDivisor;
 	__le16	wNdpOutPayloadRemainder;
 	__le16	wNdpOutAlignment;
-	__le16	wPadding2;
+	__le16	wNtbOutMaxDatagrams;
 } __attribute__ ((packed));
 
 /*
@@ -307,7 +312,7 @@ struct usb_cdc_ncm_nth16 {
 	__le16	wHeaderLength;
 	__le16	wSequence;
 	__le16	wBlockLength;
-	__le16	wFpIndex;
+	__le16	wNdpIndex;
 } __attribute__ ((packed));
 
 struct usb_cdc_ncm_nth32 {
@@ -315,7 +320,7 @@ struct usb_cdc_ncm_nth32 {
 	__le16	wHeaderLength;
 	__le16	wSequence;
 	__le32	dwBlockLength;
-	__le32	dwFpIndex;
+	__le32	dwNdpIndex;
 } __attribute__ ((packed));
 
 /*
@@ -337,7 +342,7 @@ struct usb_cdc_ncm_dpe16 {
 struct usb_cdc_ncm_ndp16 {
 	__le32	dwSignature;
 	__le16	wLength;
-	__le16	wNextFpIndex;
+	__le16	wNextNdpIndex;
 	struct	usb_cdc_ncm_dpe16 dpe16[0];
 } __attribute__ ((packed));
 
@@ -375,6 +380,7 @@ struct usb_cdc_ncm_ndp32 {
 #define USB_CDC_NCM_NCAP_ENCAP_COMMAND			(1 << 2)
 #define USB_CDC_NCM_NCAP_MAX_DATAGRAM_SIZE		(1 << 3)
 #define USB_CDC_NCM_NCAP_CRC_MODE			(1 << 4)
+#define	USB_CDC_NCM_NCAP_NTB_INPUT_SIZE			(1 << 5)
 
 /* CDC NCM subclass Table 6-3: NTB Parameter Structure */
 #define USB_CDC_NCM_NTB16_SUPPORTED			(1 << 0)
@@ -392,6 +398,13 @@ struct usb_cdc_ncm_ndp32 {
 #define USB_CDC_NCM_NTB_MIN_IN_SIZE			2048
 #define USB_CDC_NCM_NTB_MIN_OUT_SIZE			2048
 
+/* NTB Input Size Structure */
+struct usb_cdc_ncm_ndp_input_size {
+	__le32	dwNtbInMaxSize;
+	__le16	wNtbInMaxDatagrams;
+	__le16	wReserved;
+} __attribute__ ((packed));
+
 /* CDC NCM subclass 6.2.11 SetCrcMode */
 #define USB_CDC_NCM_CRC_NOT_APPENDED			0x00
 #define USB_CDC_NCM_CRC_APPENDED			0x01
-- 
1.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
