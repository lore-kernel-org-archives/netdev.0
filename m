From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 03/14] USB: cdc: add MBIM constants and structures
Date: Thu, 18 Oct 2012 22:40:56 +0200
Message-ID: <1350592867-25651-4-git-send-email-bjorn@mork.no>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Greg Suarez <gpsuarez2512-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Fangxiaozhi (Franko)" <fangxiaozhi-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Aleksander Morgado <aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1350592867-25651-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>

Based on revision 1.0 of "Universal Serial Bus Communications
Class Subclass Specification for Mobile Broadband Interface
Model" available from www.usb.org

Signed-off-by: Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>
[bmork: added DSS defines]
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
