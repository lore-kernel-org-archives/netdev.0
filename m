From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCHv2 2/7] X25: Use identifiers for isdn device to x25 interface
Date: Tue, 20 Apr 2010 09:29:06 +1000
Message-ID: <1271719746.2802.78.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:64699 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753141Ab0DSX3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 19:29:22 -0400
Received: by pva18 with SMTP id 18so3526406pva.19
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 16:29:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change magic numbers to identifiers for X25 interface.
also minor check patch formatting.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>
Acked-by: Karsten Keil <isdn@linux-pingi.de>

---
 drivers/isdn/i4l/isdn_x25iface.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_x25iface.c b/drivers/isdn/i4l/isdn_x25iface.c
index efcf1f9..fd10d7c 100644
--- a/drivers/isdn/i4l/isdn_x25iface.c
+++ b/drivers/isdn/i4l/isdn_x25iface.c
@@ -194,7 +194,7 @@ static int isdn_x25iface_receive(struct concap_proto *cprot, struct sk_buff *skb
 	if ( ( (ix25_pdata_t*) (cprot->proto_data) ) 
 	     -> state == WAN_CONNECTED ){
 		if( skb_push(skb, 1)){
-			skb -> data[0]=0x00;
+			skb->data[0] = X25_IFACE_DATA;
 			skb->protocol = x25_type_trans(skb, cprot->net_dev);
 			netif_rx(skb);
 			return 0;
@@ -224,7 +224,7 @@ static int isdn_x25iface_connect_ind(struct concap_proto *cprot)
 
 	skb = dev_alloc_skb(1);
 	if( skb ){
-		*( skb_put(skb, 1) ) = 0x01;
+		*(skb_put(skb, 1)) = X25_IFACE_CONNECT;
 		skb->protocol = x25_type_trans(skb, cprot->net_dev);
 		netif_rx(skb);
 		return 0;
@@ -253,7 +253,7 @@ static int isdn_x25iface_disconn_ind(struct concap_proto *cprot)
 	*state_p = WAN_DISCONNECTED;
 	skb = dev_alloc_skb(1);
 	if( skb ){
-		*( skb_put(skb, 1) ) = 0x02;
+		*(skb_put(skb, 1)) = X25_IFACE_DISCONNECT;
 		skb->protocol = x25_type_trans(skb, cprot->net_dev);
 		netif_rx(skb);
 		return 0;
@@ -272,9 +272,10 @@ static int isdn_x25iface_xmit(struct concap_proto *cprot, struct sk_buff *skb)
 	unsigned char firstbyte = skb->data[0];
 	enum wan_states *state = &((ix25_pdata_t*)cprot->proto_data)->state;
 	int ret = 0;
-	IX25DEBUG( "isdn_x25iface_xmit: %s first=%x state=%d \n", MY_DEVNAME(cprot -> net_dev), firstbyte, *state );
+	IX25DEBUG("isdn_x25iface_xmit: %s first=%x state=%d\n",
+		MY_DEVNAME(cprot->net_dev), firstbyte, *state);
 	switch ( firstbyte ){
-	case 0x00: /* dl_data request */
+	case X25_IFACE_DATA:
 		if( *state == WAN_CONNECTED ){
 			skb_pull(skb, 1);
 			cprot -> net_dev -> trans_start = jiffies;
@@ -285,7 +286,7 @@ static int isdn_x25iface_xmit(struct concap_proto *cprot, struct sk_buff *skb)
 		}
 		illegal_state_warn( *state, firstbyte ); 
 		break;
-	case 0x01: /* dl_connect request */
+	case X25_IFACE_CONNECT:
 		if( *state == WAN_DISCONNECTED ){
 			*state = WAN_CONNECTING;
 		        ret = cprot -> dops -> connect_req(cprot);
@@ -298,7 +299,7 @@ static int isdn_x25iface_xmit(struct concap_proto *cprot, struct sk_buff *skb)
 			illegal_state_warn( *state, firstbyte );
 		}
 		break;
-	case 0x02: /* dl_disconnect request */
+	case X25_IFACE_DISCONNECT:
 		switch ( *state ){
 		case WAN_DISCONNECTED: 
 			/* Should not happen. However, give upper layer a
@@ -318,7 +319,7 @@ static int isdn_x25iface_xmit(struct concap_proto *cprot, struct sk_buff *skb)
 			illegal_state_warn( *state, firstbyte );
 		}
 		break;
-	case 0x03: /* changing lapb parameters requested */
+	case X25_IFACE_PARAMS:
 		printk(KERN_WARNING "isdn_x25iface_xmit: setting of lapb"
 		       " options not yet supported\n");
 		break;
-- 
1.5.6.5



