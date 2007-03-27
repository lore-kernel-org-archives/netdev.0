From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 1/2] [BLUETOOTH]: Introduce skb->data accessor methods for hci_{acl,event,sco}_hdr
Date: Tue, 27 Mar 2007 16:41:32 -0300
Message-ID: <20070327194131.GB20303@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:26455 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661AbXC0Tlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 15:41:55 -0400
Received: by wr-out-0506.google.com with SMTP id 76so2091865wra
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 12:41:54 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For consistency with other skb data accessors, reducing the number of direct
accesses to skb->data.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 drivers/bluetooth/bluecard_cs.c |    6 +++---
 drivers/bluetooth/bt3c_cs.c     |    6 +++---
 drivers/bluetooth/btuart_cs.c   |    6 +++---
 drivers/bluetooth/hci_h4.c      |    6 +++---
 include/net/bluetooth/hci.h     |   18 ++++++++++++++++++
 5 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/drivers/bluetooth/bluecard_cs.c b/drivers/bluetooth/bluecard_cs.c
index acfb6a4..851de4d 100644
--- a/drivers/bluetooth/bluecard_cs.c
+++ b/drivers/bluetooth/bluecard_cs.c
@@ -461,20 +461,20 @@ static void bluecard_receive(bluecard_info_t *info, unsigned int offset)
 				switch (info->rx_state) {
 
 				case RECV_WAIT_EVENT_HEADER:
-					eh = (struct hci_event_hdr *)(info->rx_skb->data);
+					eh = hci_event_hdr(info->rx_skb);
 					info->rx_state = RECV_WAIT_DATA;
 					info->rx_count = eh->plen;
 					break;
 
 				case RECV_WAIT_ACL_HEADER:
-					ah = (struct hci_acl_hdr *)(info->rx_skb->data);
+					ah = hci_acl_hdr(info->rx_skb);
 					dlen = __le16_to_cpu(ah->dlen);
 					info->rx_state = RECV_WAIT_DATA;
 					info->rx_count = dlen;
 					break;
 
 				case RECV_WAIT_SCO_HEADER:
-					sh = (struct hci_sco_hdr *)(info->rx_skb->data);
+					sh = hci_sco_hdr(info->rx_skb);
 					info->rx_state = RECV_WAIT_DATA;
 					info->rx_count = sh->dlen;
 					break;
diff --git a/drivers/bluetooth/bt3c_cs.c b/drivers/bluetooth/bt3c_cs.c
index 18b0f39..3951607 100644
--- a/drivers/bluetooth/bt3c_cs.c
+++ b/drivers/bluetooth/bt3c_cs.c
@@ -303,20 +303,20 @@ static void bt3c_receive(bt3c_info_t *info)
 				switch (info->rx_state) {
 
 				case RECV_WAIT_EVENT_HEADER:
-					eh = (struct hci_event_hdr *)(info->rx_skb->data);
+					eh = hci_event_hdr(info->rx_skb);
 					info->rx_state = RECV_WAIT_DATA;
 					info->rx_count = eh->plen;
 					break;
 
 				case RECV_WAIT_ACL_HEADER:
-					ah = (struct hci_acl_hdr *)(info->rx_skb->data);
+					ah = hci_acl_hdr(info->rx_skb);
 					dlen = __le16_to_cpu(ah->dlen);
 					info->rx_state = RECV_WAIT_DATA;
 					info->rx_count = dlen;
 					break;
 
 				case RECV_WAIT_SCO_HEADER:
-					sh = (struct hci_sco_hdr *)(info->rx_skb->data);
+					sh = hci_sco_hdr(info->rx_skb);
 					info->rx_state = RECV_WAIT_DATA;
 					info->rx_count = sh->dlen;
 					break;
diff --git a/drivers/bluetooth/btuart_cs.c b/drivers/bluetooth/btuart_cs.c
index c1bce75..d7d2ea0 100644
--- a/drivers/bluetooth/btuart_cs.c
+++ b/drivers/bluetooth/btuart_cs.c
@@ -250,20 +250,20 @@ static void btuart_receive(btuart_info_t *info)
 				switch (info->rx_state) {
 
 				case RECV_WAIT_EVENT_HEADER:
-					eh = (struct hci_event_hdr *)(info->rx_skb->data);
+					eh = hci_event_hdr(info->rx_skb);
 					info->rx_state = RECV_WAIT_DATA;
 					info->rx_count = eh->plen;
 					break;
 
 				case RECV_WAIT_ACL_HEADER:
-					ah = (struct hci_acl_hdr *)(info->rx_skb->data);
+					ah = hci_acl_hdr(info->rx_skb);
 					dlen = __le16_to_cpu(ah->dlen);
 					info->rx_state = RECV_WAIT_DATA;
 					info->rx_count = dlen;
 					break;
 
 				case RECV_WAIT_SCO_HEADER:
-					sh = (struct hci_sco_hdr *)(info->rx_skb->data);
+					sh = hci_sco_hdr(info->rx_skb);
 					info->rx_state = RECV_WAIT_DATA;
 					info->rx_count = sh->dlen;
 					break;
diff --git a/drivers/bluetooth/hci_h4.c b/drivers/bluetooth/hci_h4.c
index 34f0afc..bfbae14 100644
--- a/drivers/bluetooth/hci_h4.c
+++ b/drivers/bluetooth/hci_h4.c
@@ -188,7 +188,7 @@ static int h4_recv(struct hci_uart *hu, void *data, int count)
 				continue;
 
 			case H4_W4_EVENT_HDR:
-				eh = (struct hci_event_hdr *) h4->rx_skb->data;
+				eh = hci_event_hdr(h4->rx_skb);
 
 				BT_DBG("Event header: evt 0x%2.2x plen %d", eh->evt, eh->plen);
 
@@ -196,7 +196,7 @@ static int h4_recv(struct hci_uart *hu, void *data, int count)
 				continue;
 
 			case H4_W4_ACL_HDR:
-				ah = (struct hci_acl_hdr *) h4->rx_skb->data;
+				ah = hci_acl_hdr(h4->rx_skb);
 				dlen = __le16_to_cpu(ah->dlen);
 
 				BT_DBG("ACL header: dlen %d", dlen);
@@ -205,7 +205,7 @@ static int h4_recv(struct hci_uart *hu, void *data, int count)
 				continue;
 
 			case H4_W4_SCO_HDR:
-				sh = (struct hci_sco_hdr *) h4->rx_skb->data;
+				sh = hci_sco_hdr(h4->rx_skb);
 
 				BT_DBG("SCO header: dlen %d", sh->dlen);
 
diff --git a/include/net/bluetooth/hci.h b/include/net/bluetooth/hci.h
index 41456c1..93ce272 100644
--- a/include/net/bluetooth/hci.h
+++ b/include/net/bluetooth/hci.h
@@ -709,6 +709,24 @@ struct hci_sco_hdr {
 	__u8 	dlen;
 } __attribute__ ((packed));
 
+#ifdef __KERNEL__
+#include <linux/skbuff.h>
+static inline struct hci_event_hdr *hci_event_hdr(const struct sk_buff *skb)
+{
+	return (struct hci_event_hdr *)skb->data;
+}
+
+static inline struct hci_acl_hdr *hci_acl_hdr(const struct sk_buff *skb)
+{
+	return (struct hci_acl_hdr *)skb->data;
+}
+
+static inline struct hci_sco_hdr *hci_sco_hdr(const struct sk_buff *skb)
+{
+	return (struct hci_sco_hdr *)skb->data;
+}
+#endif
+
 /* Command opcode pack/unpack */
 #define hci_opcode_pack(ogf, ocf)	(__u16) ((ocf & 0x03ff)|(ogf << 10))
 #define hci_opcode_ogf(op)		(op >> 10)
-- 
1.5.0.5

