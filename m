From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next 02/13] USB: cdc: add MBIM constants and structures
Date: Mon, 22 Oct 2012 22:56:29 +0200
Message-ID: <1350939400-27209-3-git-send-email-bjorn@mork.no>
References: <1350939400-27209-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Greg Suarez <gpsuarez2512@gmail.com>,
	"Fangxiaozhi (Franko)" <fangxiaozhi@huawei.com>,
	Dan Williams <dcbw@redhat.com>,
	Aleksander Morgado <aleksander@lanedo.com>,
	Greg Suarez <gsuarez@smithmicro.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48608 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756386Ab2JVU5X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2012 16:57:23 -0400
In-Reply-To: <1350939400-27209-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Greg Suarez <gsuarez@smithmicro.com>

Based on revision 1.0 of "Universal Serial Bus Communications
Class Subclass Specification for Mobile Broadband Interface
Model" available from www.usb.org

Signed-off-by: Greg Suarez <gsuarez@smithmicro.com>
[bmork: added DSS defines]
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 include/linux/usb/cdc.h |   23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/include/linux/usb/cdc.h b/include/linux/usb/cdc.h
index 81a9279..f35aa0a 100644
--- a/include/linux/usb/cdc.h
+++ b/include/linux/usb/cdc.h
@@ -19,6 +19,7 @@
 #define USB_CDC_SUBCLASS_OBEX			0x0b
 #define USB_CDC_SUBCLASS_EEM			0x0c
 #define USB_CDC_SUBCLASS_NCM			0x0d
+#define USB_CDC_SUBCLASS_MBIM			0x0e
=20
 #define USB_CDC_PROTO_NONE			0
=20
@@ -33,6 +34,7 @@
 #define USB_CDC_PROTO_EEM			7
=20
 #define USB_CDC_NCM_PROTO_NTB			1
+#define USB_CDC_MBIM_PROTO_NTB			2
=20
 /*--------------------------------------------------------------------=
-----*/
=20
@@ -53,6 +55,7 @@
 #define USB_CDC_DMM_TYPE		0x14
 #define USB_CDC_OBEX_TYPE		0x15
 #define USB_CDC_NCM_TYPE		0x1a
+#define USB_CDC_MBIM_TYPE		0x1b
=20
 /* "Header Functional Descriptor" from CDC spec  5.2.3.1 */
 struct usb_cdc_header_desc {
@@ -187,6 +190,21 @@ struct usb_cdc_ncm_desc {
 	__le16	bcdNcmVersion;
 	__u8	bmNetworkCapabilities;
 } __attribute__ ((packed));
+
+/* "MBIM Control Model Functional Descriptor" */
+struct usb_cdc_mbim_desc {
+	__u8	bLength;
+	__u8	bDescriptorType;
+	__u8	bDescriptorSubType;
+
+	__le16	bcdMBIMVersion;
+	__le16  wMaxControlMessage;
+	__u8    bNumberFilters;
+	__u8    bMaxFilterSize;
+	__le16  wMaxSegmentSize;
+	__u8    bmNetworkCapabilities;
+} __attribute__ ((packed));
+
 /*--------------------------------------------------------------------=
-----*/
=20
 /*
@@ -332,6 +350,11 @@ struct usb_cdc_ncm_nth32 {
 #define USB_CDC_NCM_NDP32_CRC_SIGN	0x316D636E /* ncm1 */
 #define USB_CDC_NCM_NDP32_NOCRC_SIGN	0x306D636E /* ncm0 */
=20
+#define USB_CDC_MBIM_NDP16_IPS_SIGN     0x00535049 /* IPS<sessionID> :=
 IPS0 for now */
+#define USB_CDC_MBIM_NDP32_IPS_SIGN     0x00737069 /* ips<sessionID> :=
 ips0 for now */
+#define USB_CDC_MBIM_NDP16_DSS_SIGN     0x00535344 /* DSS<sessionID> *=
/
+#define USB_CDC_MBIM_NDP32_DSS_SIGN     0x00737364 /* dss<sessionID> *=
/
+
 /* 16-bit NCM Datagram Pointer Entry */
 struct usb_cdc_ncm_dpe16 {
 	__le16	wDatagramIndex;
--=20
1.7.10.4
