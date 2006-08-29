From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Removed unneeded packed attributes
Date: Tue, 29 Aug 2006 23:51:43 +0100 (BST)
Message-ID: <20060829225143.AD4637B40A0@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:58690 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S965154AbWH2Wtb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 18:49:31 -0400
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune@deine-taler.de>

Inspired by an e-mail by Stephen Hemminger I decided to remove all
unneeded packed attributes from the code where the member variables are
already aligned. This avoids horrible code being generated on some
architectures.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_ieee80211.h |    2 +-
 zd_mac.c       |    2 +-
 zd_mac.h       |    4 ++--
 zd_usb.h       |   14 +++++++-------
 4 files changed, 11 insertions(+), 11 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_ieee80211.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_ieee80211.h
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_ieee80211.h
@@ -64,7 +64,7 @@ struct cck_plcp_header {
 	u8 service;
 	__le16 length;
 	__le16 crc16;
-} __attribute__((packed));
+};
 
 static inline u8 zd_cck_plcp_header_rate(const struct cck_plcp_header *header)
 {
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_mac.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -714,7 +714,7 @@ struct zd_rt_hdr {
 	u8  rt_rate;
 	u16 rt_channel;
 	u16 rt_chbitmask;
-} __attribute__((packed));
+};
 
 static void fill_rt_header(void *buffer, struct zd_mac *mac,
 	                   const struct ieee80211_rx_stats *stats,
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_mac.h
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.h
@@ -82,7 +82,7 @@ struct zd_ctrlset {
 struct rx_length_info {
 	__le16 length[3];
 	__le16 tag;
-} __attribute__((packed));
+};
 
 #define RX_LENGTH_INFO_TAG		0x697e
 
@@ -93,7 +93,7 @@ struct rx_status {
 	u8 signal_quality_ofdm;
 	u8 decryption_type;
 	u8 frame_status;
-} __attribute__((packed));
+};
 
 /* rx_status field decryption_type */
 #define ZD_RX_NO_WEP	0
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_usb.h
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.h
@@ -74,17 +74,17 @@ enum control_requests {
 struct usb_req_read_regs {
 	__le16 id;
 	__le16 addr[0];
-} __attribute__((packed));
+};
 
 struct reg_data {
 	__le16 addr;
 	__le16 value;
-} __attribute__((packed));
+};
 
 struct usb_req_write_regs {
 	__le16 id;
 	struct reg_data reg_writes[0];
-} __attribute__((packed));
+};
 
 enum {
 	RF_IF_LE = 0x02,
@@ -101,7 +101,7 @@ struct usb_req_rfwrite {
 	/* RF2595: 24 */
 	__le16 bit_values[0];
 	/* (CR203 & ~(RF_IF_LE | RF_CLK | RF_DATA)) | (bit ? RF_DATA : 0) */
-} __attribute__((packed));
+};
 
 /* USB interrupt */
 
@@ -118,12 +118,12 @@ enum usb_int_flags {
 struct usb_int_header {
 	u8 type;	/* must always be 1 */
 	u8 id;
-} __attribute__((packed));
+};
 
 struct usb_int_regs {
 	struct usb_int_header hdr;
 	struct reg_data regs[0];
-} __attribute__((packed));
+};
 
 struct usb_int_retry_fail {
 	struct usb_int_header hdr;
@@ -131,7 +131,7 @@ struct usb_int_retry_fail {
 	u8 _dummy;
 	u8 addr[ETH_ALEN];
 	u8 ibss_wakeup_dest;
-} __attribute__((packed));
+};
 
 struct read_regs_int {
 	struct completion completion;
