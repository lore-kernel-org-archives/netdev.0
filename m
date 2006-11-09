From: akpm@osdl.org
Subject: [patch 7/9] rfcomm endianness annotations
Date: Wed, 08 Nov 2006 19:51:09 -0800
Message-ID: <200611090351.kA93p9hK003696@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, viro@ftp.linux.org.uk,
	marcel@holtmann.org, viro@zeniv.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:24751 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161801AbWKIDv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 22:51:26 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ftp.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Acked-by: Marcel Holtmann <marcel@holtmann.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/net/bluetooth/rfcomm.h |    4 ++--
 net/bluetooth/rfcomm/core.c    |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff -puN include/net/bluetooth/rfcomm.h~rfcomm-endianness-annotations include/net/bluetooth/rfcomm.h
--- a/include/net/bluetooth/rfcomm.h~rfcomm-endianness-annotations
+++ a/include/net/bluetooth/rfcomm.h
@@ -124,7 +124,7 @@ struct rfcomm_pn {
 	u8  flow_ctrl;
 	u8  priority;
 	u8  ack_timer;
-	u16 mtu;
+	__le16 mtu;
 	u8  max_retrans;
 	u8  credits;
 } __attribute__ ((packed));
@@ -136,7 +136,7 @@ struct rfcomm_rpn {
 	u8  flow_ctrl;
 	u8  xon_char;
 	u8  xoff_char;
-	u16 param_mask;
+	__le16 param_mask;
 } __attribute__ ((packed));
 
 struct rfcomm_rls {
diff -puN net/bluetooth/rfcomm/core.c~rfcomm-endianness-annotations net/bluetooth/rfcomm/core.c
--- a/net/bluetooth/rfcomm/core.c~rfcomm-endianness-annotations
+++ a/net/bluetooth/rfcomm/core.c
@@ -1018,7 +1018,7 @@ static void rfcomm_make_uih(struct sk_bu
 
 	if (len > 127) {
 		hdr = (void *) skb_push(skb, 4);
-		put_unaligned(htobs(__len16(len)), (u16 *) &hdr->len);
+		put_unaligned(htobs(__len16(len)), (__le16 *) &hdr->len);
 	} else {
 		hdr = (void *) skb_push(skb, 3);
 		hdr->len = __len8(len);
_
