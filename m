From: Matthew J Galgoci <mgalgoci@parcelfarce.linux.theplanet.co.uk>
Subject: [patch] wireless-2.6 stuff
Date: Mon, 14 Feb 2005 01:04:36 +0000 (GMT)
Message-ID: <Pine.LNX.4.58.0502140056290.4356@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: jgarzik@pobox.corp, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Jeff,

Here are some basic no-brainer stuff for wireless-2.6. I don't have any atmel hardware
to test though.

Matt

 drivers/net/wireless/ieee802_11.h |   78 --------------------------------------
 drivers/net/wireless/Kconfig      |   46 ++++++++--------------
 drivers/net/wireless/atmel.c      |   62 +++++++++++++++---------------
 drivers/net/wireless/orinoco.c    |   11 ++---
 drivers/net/wireless/todo.txt     |    2 
 drivers/net/wireless/wl3501.h     |    4 -
 6 files changed, 59 insertions(+), 144 deletions(-)

through these ChangeSets:

<mgalgoci@xeon.clusterfsck.org> (05/02/13 1.2033)
   - convert various drivers to use <net/ieee80211.h>
   - mark obsolete pre-802.11 radios

diff -Nru a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
--- a/drivers/net/wireless/Kconfig	2005-02-13 19:18:22 -05:00
+++ b/drivers/net/wireless/Kconfig	2005-02-13 19:18:22 -05:00
@@ -6,7 +6,7 @@
 	depends on NETDEVICES
 
 config NET_RADIO
-	bool "Wireless LAN drivers (non-hamradio) & Wireless Extensions"
+	bool "Wireless LAN drivers (non-hamradio) and Wireless Extensions"
 	---help---
 	  Support for wireless LANs and everything having to do with radio,
 	  but not with amateur radio or FM broadcasting.
@@ -24,18 +24,12 @@
 	  the tools from
 	  <http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/Tools.html>.
 
-	  Some user-level drivers for scarab devices which don't require
-	  special kernel support are available from
-	  <ftp://shadow.cabi.net/pub/Linux/>.
-
-# Note : the cards are obsolete (can't buy them anymore), but the drivers
-# are not, as people are still using them...
-comment "Obsolete Wireless cards support (pre-802.11)"
-	depends on NET_RADIO && (INET || ISA || PCMCIA)
+comment "Obsolete Wireless cards support (pre-802.11) (OBSOLETE)"
+	depends on NET_RADIO && (INET || ISA || PCMCIA) && OBSOLETE
 
 config STRIP
-	tristate "STRIP (Metricom starmode radio IP)"
-	depends on NET_RADIO && INET
+	tristate "STRIP (Metricom starmode radio IP) (OBSOLETE)"
+	depends on NET_RADIO && INET && OBSOLETE
 	---help---
 	  Say Y if you have a Metricom radio and intend to use Starmode Radio
 	  IP. STRIP is a radio protocol developed for the MosquitoNet project
@@ -57,23 +51,19 @@
 	  called strip.
 
 config ARLAN
-	tristate "Aironet Arlan 655 & IC2200 DS support"
-	depends on NET_RADIO && ISA && !64BIT
+	tristate "Aironet Arlan 655 & IC2200 DS support (OBSOLETE)"
+	depends on NET_RADIO && ISA && !64BIT && OBSOLETE
 	---help---
 	  Aironet makes Arlan, a class of wireless LAN adapters. These use the
 	  www.Telxon.com chip, which is also used on several similar cards.
-	  This driver is tested on the 655 and IC2200 series cards. Look at
-	  <http://www.ylenurme.ee/~elmer/655/> for the latest information.
+	  This driver is tested on the 655 and IC2200 series cards.
 
 	  The driver is built as two modules, arlan and arlan-proc. The latter
 	  is the /proc interface and is not needed most of time.
 
-	  On some computers the card ends up in non-valid state after some
-	  time. Use a ping-reset script to clear it.
-
 config WAVELAN
-	tristate "AT&T/Lucent old WaveLAN & DEC RoamAbout DS ISA support"
-	depends on NET_RADIO && ISA
+	tristate "AT&T/Lucent old WaveLAN & DEC RoamAbout DS ISA support (OBSOLETE)"
+	depends on NET_RADIO && ISA && OBSOLETE
 	---help---
 	  The Lucent WaveLAN (formerly NCR and AT&T; or DEC RoamAbout DS) is
 	  a Radio LAN (wireless Ethernet-like Local Area Network) using the
@@ -99,8 +89,8 @@
 	  called wavelan.
 
 config PCMCIA_WAVELAN
-	tristate "AT&T/Lucent old WaveLAN Pcmcia wireless support"
-	depends on NET_RADIO && PCMCIA
+	tristate "AT&T/Lucent old WaveLAN Pcmcia wireless support (OBSOLETE)"
+	depends on NET_RADIO && PCMCIA && OBSOLETE
 	help
 	  Say Y here if you intend to attach an AT&T/Lucent Wavelan PCMCIA
 	  (PC-card) wireless Ethernet networking card to your computer.  This
@@ -110,8 +100,8 @@
 	  called wavelan_cs.  If unsure, say N.
 
 config PCMCIA_NETWAVE
-	tristate "Xircom Netwave AirSurfer Pcmcia wireless support"
-	depends on NET_RADIO && PCMCIA
+	tristate "Xircom Netwave AirSurfer Pcmcia wireless support (OBSOLETE)"
+	depends on NET_RADIO && PCMCIA && OBSOLETE
 	help
 	  Say Y here if you intend to attach this type of PCMCIA (PC-card)
 	  wireless Ethernet networking card to your computer.
@@ -119,12 +109,12 @@
 	  To compile this driver as a module, choose M here: the module will be
 	  called netwave_cs.  If unsure, say N.
 
-comment "Wireless 802.11 Frequency Hopping cards support"
-	depends on NET_RADIO && PCMCIA
+comment "Wireless 802.11 Frequency Hopping cards support (OBSOLETE)"
+	depends on NET_RADIO && PCMCIA && OBSOLETE
 
 config PCMCIA_RAYCS
-	tristate "Aviator/Raytheon 2.4MHz wireless support"
-	depends on NET_RADIO && PCMCIA
+	tristate "Aviator/Raytheon 2.4MHz wireless support (OBSOLETE)"
+	depends on NET_RADIO && PCMCIA && OBSOLETE
 	---help---
 	  Say Y here if you intend to attach an Aviator/Raytheon PCMCIA
 	  (PC-card) wireless Ethernet networking card to your computer.
diff -Nru a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
--- a/drivers/net/wireless/atmel.c	2005-02-13 19:18:22 -05:00
+++ b/drivers/net/wireless/atmel.c	2005-02-13 19:18:22 -05:00
@@ -68,7 +68,7 @@
 #include <linux/device.h>
 #include <linux/moduleparam.h>
 #include <linux/firmware.h>
-#include "ieee802_11.h"
+#include <net/ieee80211.h>
 
 #define DRIVER_MAJOR 0
 #define DRIVER_MINOR 96
@@ -600,12 +600,12 @@
 static void atmel_wmem32(struct atmel_private *priv, u16 pos, u32 data);
 static void atmel_command_irq(struct atmel_private *priv);
 static int atmel_validate_channel(struct atmel_private *priv, int channel);
-static void atmel_management_frame(struct atmel_private *priv, struct ieee802_11_hdr *header, 
+static void atmel_management_frame(struct atmel_private *priv, struct ieee80211_hdr *header, 
 				   u16 frame_len, u8 rssi);
 static void atmel_management_timer(u_long a);
 static void atmel_send_command(struct atmel_private *priv, int command, void *cmd, int cmd_size);
 static int atmel_send_command_wait(struct atmel_private *priv, int command, void *cmd, int cmd_size);
-static void atmel_transmit_management_frame(struct atmel_private *priv, struct ieee802_11_hdr *header,
+static void atmel_transmit_management_frame(struct atmel_private *priv, struct ieee80211_hdr *header,
 					    u8 *body, int body_len);
 
 static u8 atmel_get_mib8(struct atmel_private *priv, u8 type, u8 index);
@@ -809,7 +809,7 @@
 static int start_tx (struct sk_buff *skb, struct net_device *dev)
 {
 	struct atmel_private *priv = netdev_priv(dev);
-	struct ieee802_11_hdr header;
+	struct ieee80211_hdr header;
 	unsigned long flags;
 	u16 buff, frame_ctl, len = (ETH_ZLEN < skb->len) ? skb->len : ETH_ZLEN;
 	u8 SNAP_RFC1024[6] = {0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00};
@@ -845,17 +845,17 @@
 		return 1;
 	}
 	
-	frame_ctl = IEEE802_11_FTYPE_DATA;
+	frame_ctl = IEEE80211_FTYPE_DATA;
 	header.duration_id = 0;
 	header.seq_ctl = 0;
 	if (priv->wep_is_on)
-		frame_ctl |= IEEE802_11_FCTL_WEP;
+		frame_ctl |= IEEE80211_FCTL_WEP;
 	if (priv->operating_mode == IW_MODE_ADHOC) {
 		memcpy(&header.addr1, skb->data, 6);
 		memcpy(&header.addr2, dev->dev_addr, 6);
 		memcpy(&header.addr3, priv->BSSID, 6);
 	} else {
-		frame_ctl |= IEEE802_11_FCTL_TODS;
+		frame_ctl |= IEEE80211_FCTL_TODS;
 		memcpy(&header.addr1, priv->CurrentBSSID, 6);
 		memcpy(&header.addr2, dev->dev_addr, 6);
 		memcpy(&header.addr3, skb->data, 6);
@@ -884,7 +884,7 @@
 }
 
 static void atmel_transmit_management_frame(struct atmel_private *priv, 
-					    struct ieee802_11_hdr *header,
+					    struct ieee80211_hdr *header,
 					    u8 *body, int body_len)
 {
 	u16 buff;
@@ -899,7 +899,7 @@
 	tx_update_descriptor(priv, header->addr1[0] & 0x01, len, buff, TX_PACKET_TYPE_MGMT);
 }
 	
-static void fast_rx_path(struct atmel_private *priv, struct ieee802_11_hdr *header, 
+static void fast_rx_path(struct atmel_private *priv, struct ieee80211_hdr *header, 
 			 u16 msdu_size, u16 rx_packet_loc, u32 crc)
 {
 	/* fast path: unfragmented packet copy directly into skbuf */
@@ -937,7 +937,7 @@
 	}
 	
 	memcpy(skbp, header->addr1, 6); /* destination address */
-	if (le16_to_cpu(header->frame_ctl) & IEEE802_11_FCTL_FROMDS) 
+	if (le16_to_cpu(header->frame_ctl) & IEEE80211_FCTL_FROMDS) 
 		memcpy(&skbp[6], header->addr3, 6);
 	else
 		memcpy(&skbp[6], header->addr2, 6); /* source address */
@@ -972,14 +972,14 @@
 	return (crc ^ 0xffffffff) == netcrc;
 }
 
-static void frag_rx_path(struct atmel_private *priv, struct ieee802_11_hdr *header, 
+static void frag_rx_path(struct atmel_private *priv, struct ieee80211_hdr *header, 
 			 u16 msdu_size, u16 rx_packet_loc, u32 crc, u16 seq_no, u8 frag_no, int more_frags)
 {
 	u8 mac4[6]; 
 	u8 source[6];
 	struct sk_buff *skb;
 
-	if (le16_to_cpu(header->frame_ctl) & IEEE802_11_FCTL_FROMDS) 
+	if (le16_to_cpu(header->frame_ctl) & IEEE80211_FCTL_FROMDS) 
 		memcpy(source, header->addr3, 6);
 	else
 		memcpy(source, header->addr2, 6); 
@@ -1064,7 +1064,7 @@
 static void rx_done_irq(struct atmel_private *priv)
 {
 	int i;
-	struct ieee802_11_hdr header;
+	struct ieee80211_hdr header;
 	
 	for (i = 0; 
 	     atmel_rmem8(priv, atmel_rx(priv, RX_DESC_FLAGS_OFFSET, priv->rx_desc_head)) == RX_DESC_FLAG_VALID &&
@@ -1099,7 +1099,7 @@
 		/* probe for CRC use here if needed  once five packets have arrived with
 		   the same crc status, we assume we know what's happening and stop probing */
 		if (priv->probe_crc) {
-			if (!priv->wep_is_on || !(frame_ctl & IEEE802_11_FCTL_WEP)) {
+			if (!priv->wep_is_on || !(frame_ctl & IEEE80211_FCTL_WEP)) {
 				priv->do_rx_crc = probe_crc(priv, rx_packet_loc, msdu_size);
 			} else {
 				priv->do_rx_crc = probe_crc(priv, rx_packet_loc + 24, msdu_size - 24);
@@ -1114,16 +1114,16 @@
 		}
 		    
 		/* don't CRC header when WEP in use */
-		if (priv->do_rx_crc && (!priv->wep_is_on || !(frame_ctl & IEEE802_11_FCTL_WEP))) {
+		if (priv->do_rx_crc && (!priv->wep_is_on || !(frame_ctl & IEEE80211_FCTL_WEP))) {
 			crc = crc32_le(0xffffffff, (unsigned char *)&header, 24);
 		}
 		msdu_size -= 24; /* header */
 
-		if ((frame_ctl & IEEE802_11_FCTL_FTYPE) == IEEE802_11_FTYPE_DATA) { 
+		if ((frame_ctl & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA) { 
 			
-			int more_fragments = frame_ctl & IEEE802_11_FCTL_MOREFRAGS;
-			u8 packet_fragment_no = seq_control & IEEE802_11_SCTL_FRAG;
-			u16 packet_sequence_no = (seq_control & IEEE802_11_SCTL_SEQ) >> 4;
+			int more_fragments = frame_ctl & IEEE80211_FCTL_MOREFRAGS;
+			u8 packet_fragment_no = seq_control & IEEE80211_SCTL_FRAG;
+			u16 packet_sequence_no = (seq_control & IEEE80211_SCTL_SEQ) >> 4;
 			
 			if (!more_fragments && packet_fragment_no == 0 ) {
 				fast_rx_path(priv, &header, msdu_size, rx_packet_loc, crc);
@@ -1133,7 +1133,7 @@
 			}
 		}
 		
-		if ((frame_ctl & IEEE802_11_FCTL_FTYPE) == IEEE802_11_FTYPE_MGMT) {
+		if ((frame_ctl & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT) {
 			/* copy rest of packet into buffer */
 			atmel_copy_to_host(priv->dev, (unsigned char *)&priv->rx_buf, rx_packet_loc + 24, msdu_size);
 			
@@ -2637,10 +2637,10 @@
  
 static void send_authentication_request(struct atmel_private *priv, u8 *challenge, int challenge_len)
 {
-	struct ieee802_11_hdr header;
+	struct ieee80211_hdr header;
 	struct auth_body auth;
 	
-	header.frame_ctl = cpu_to_le16(IEEE802_11_FTYPE_MGMT | IEEE802_11_STYPE_AUTH); 
+	header.frame_ctl = cpu_to_le16(IEEE80211_FTYPE_MGMT | IEEE80211_STYPE_AUTH); 
 	header.duration_id	= cpu_to_le16(0x8000);	
 	header.seq_ctl = 0;
 	memcpy(header.addr1, priv->CurrentBSSID, 6);
@@ -2651,7 +2651,7 @@
 		auth.alg = cpu_to_le16(C80211_MGMT_AAN_SHAREDKEY); 
 		/* no WEP for authentication frames with TrSeqNo 1 */
 		if (priv->CurrentAuthentTransactionSeqNum != 1)
-			header.frame_ctl |=  cpu_to_le16(IEEE802_11_FCTL_WEP); 
+			header.frame_ctl |=  cpu_to_le16(IEEE80211_FCTL_WEP); 
 	} else {
 		auth.alg = cpu_to_le16(C80211_MGMT_AAN_OPENSYSTEM);
 	}
@@ -2675,7 +2675,7 @@
 {
 	u8 *ssid_el_p;
 	int bodysize;
-	struct ieee802_11_hdr header;
+	struct ieee80211_hdr header;
 	struct ass_req_format {
 		u16 capability;
 		u16 listen_interval; 
@@ -2688,8 +2688,8 @@
 		u8 rates[4];
 	} body;
 		
-	header.frame_ctl = cpu_to_le16(IEEE802_11_FTYPE_MGMT | 
-		(is_reassoc ? IEEE802_11_STYPE_REASSOC_REQ : IEEE802_11_STYPE_ASSOC_REQ));
+	header.frame_ctl = cpu_to_le16(IEEE80211_FTYPE_MGMT | 
+		(is_reassoc ? IEEE80211_STYPE_REASSOC_REQ : IEEE80211_STYPE_ASSOC_REQ));
 	header.duration_id = cpu_to_le16(0x8000);
 	header.seq_ctl = 0;
 
@@ -2725,9 +2725,9 @@
 	atmel_transmit_management_frame(priv, &header, (void *)&body, bodysize);
 }
 
-static int is_frame_from_current_bss(struct atmel_private *priv, struct ieee802_11_hdr *header)
+static int is_frame_from_current_bss(struct atmel_private *priv, struct ieee80211_hdr *header)
 {
-	if (le16_to_cpu(header->frame_ctl) & IEEE802_11_FCTL_FROMDS)
+	if (le16_to_cpu(header->frame_ctl) & IEEE80211_FCTL_FROMDS)
 		return memcmp(header->addr3, priv->CurrentBSSID, 6) == 0;
 	else
 		return memcmp(header->addr2, priv->CurrentBSSID, 6) == 0;
@@ -2775,7 +2775,7 @@
 }
 
 
-static void store_bss_info(struct atmel_private *priv, struct ieee802_11_hdr *header,
+static void store_bss_info(struct atmel_private *priv, struct ieee80211_hdr *header,
 			   u16 capability, u16 beacon_period, u8 channel, u8 rssi, 
 			   u8 ssid_len, u8 *ssid, int is_beacon)
 {
@@ -3050,12 +3050,12 @@
 }
 	
 /* deals with incoming managment frames. */
-static void atmel_management_frame(struct atmel_private *priv, struct ieee802_11_hdr *header, 
+static void atmel_management_frame(struct atmel_private *priv, struct ieee80211_hdr *header, 
 		      u16 frame_len, u8 rssi)
 {
 	u16 subtype;
 	
-	switch (subtype = le16_to_cpu(header->frame_ctl) & IEEE802_11_FCTL_STYPE) {
+	switch (subtype = le16_to_cpu(header->frame_ctl) & IEEE80211_FCTL_STYPE) {
 	case C80211_SUBTYPE_MGMT_BEACON :
 	case C80211_SUBTYPE_MGMT_ProbeResponse:
 		
diff -Nru a/drivers/net/wireless/ieee802_11.h b/drivers/net/wireless/ieee802_11.h
--- a/drivers/net/wireless/ieee802_11.h	2005-02-13 19:18:22 -05:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,78 +0,0 @@
-#ifndef _IEEE802_11_H
-#define _IEEE802_11_H
-
-#define IEEE802_11_DATA_LEN		2304
-/* Maximum size for the MA-UNITDATA primitive, 802.11 standard section
-   6.2.1.1.2.
-
-   The figure in section 7.1.2 suggests a body size of up to 2312
-   bytes is allowed, which is a bit confusing, I suspect this
-   represents the 2304 bytes of real data, plus a possible 8 bytes of
-   WEP IV and ICV. (this interpretation suggested by Ramiro Barreiro) */
-
-
-#define IEEE802_11_HLEN			30
-#define IEEE802_11_FRAME_LEN		(IEEE802_11_DATA_LEN + IEEE802_11_HLEN)
-
-struct ieee802_11_hdr {
-	u16 frame_ctl;
-	u16 duration_id;
-	u8 addr1[ETH_ALEN];
-	u8 addr2[ETH_ALEN];
-	u8 addr3[ETH_ALEN];
-	u16 seq_ctl;
-	u8 addr4[ETH_ALEN];
-} __attribute__ ((packed));
-
-/* Frame control field constants */
-#define IEEE802_11_FCTL_VERS		0x0002
-#define IEEE802_11_FCTL_FTYPE		0x000c
-#define IEEE802_11_FCTL_STYPE		0x00f0
-#define IEEE802_11_FCTL_TODS		0x0100
-#define IEEE802_11_FCTL_FROMDS		0x0200
-#define IEEE802_11_FCTL_MOREFRAGS	0x0400
-#define IEEE802_11_FCTL_RETRY		0x0800
-#define IEEE802_11_FCTL_PM		0x1000
-#define IEEE802_11_FCTL_MOREDATA	0x2000
-#define IEEE802_11_FCTL_WEP		0x4000
-#define IEEE802_11_FCTL_ORDER		0x8000
-
-#define IEEE802_11_FTYPE_MGMT		0x0000
-#define IEEE802_11_FTYPE_CTL		0x0004
-#define IEEE802_11_FTYPE_DATA		0x0008
-
-/* management */
-#define IEEE802_11_STYPE_ASSOC_REQ	0x0000
-#define IEEE802_11_STYPE_ASSOC_RESP 	0x0010
-#define IEEE802_11_STYPE_REASSOC_REQ	0x0020
-#define IEEE802_11_STYPE_REASSOC_RESP	0x0030
-#define IEEE802_11_STYPE_PROBE_REQ	0x0040
-#define IEEE802_11_STYPE_PROBE_RESP	0x0050
-#define IEEE802_11_STYPE_BEACON		0x0080
-#define IEEE802_11_STYPE_ATIM		0x0090
-#define IEEE802_11_STYPE_DISASSOC	0x00A0
-#define IEEE802_11_STYPE_AUTH		0x00B0
-#define IEEE802_11_STYPE_DEAUTH		0x00C0
-
-/* control */
-#define IEEE802_11_STYPE_PSPOLL		0x00A0
-#define IEEE802_11_STYPE_RTS		0x00B0
-#define IEEE802_11_STYPE_CTS		0x00C0
-#define IEEE802_11_STYPE_ACK		0x00D0
-#define IEEE802_11_STYPE_CFEND		0x00E0
-#define IEEE802_11_STYPE_CFENDACK	0x00F0
-
-/* data */
-#define IEEE802_11_STYPE_DATA		0x0000
-#define IEEE802_11_STYPE_DATA_CFACK	0x0010
-#define IEEE802_11_STYPE_DATA_CFPOLL	0x0020
-#define IEEE802_11_STYPE_DATA_CFACKPOLL	0x0030
-#define IEEE802_11_STYPE_NULLFUNC	0x0040
-#define IEEE802_11_STYPE_CFACK		0x0050
-#define IEEE802_11_STYPE_CFPOLL		0x0060
-#define IEEE802_11_STYPE_CFACKPOLL	0x0070
-
-#define IEEE802_11_SCTL_FRAG		0x000F
-#define IEEE802_11_SCTL_SEQ		0xFFF0
-
-#endif /* _IEEE802_11_H */
diff -Nru a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
--- a/drivers/net/wireless/orinoco.c	2005-02-13 19:18:22 -05:00
+++ b/drivers/net/wireless/orinoco.c	2005-02-13 19:18:22 -05:00
@@ -441,6 +441,8 @@
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
 
+#include <net/ieee80211.h>
+
 #include <asm/uaccess.h>
 #include <asm/io.h>
 #include <asm/system.h>
@@ -448,7 +450,6 @@
 #include "hermes.h"
 #include "hermes_rid.h"
 #include "orinoco.h"
-#include "ieee802_11.h"
 
 /********************************************************************/
 /* Module information                                               */
@@ -484,7 +485,7 @@
 /********************************************************************/
 
 #define ORINOCO_MIN_MTU		256
-#define ORINOCO_MAX_MTU		(IEEE802_11_DATA_LEN - ENCAPS_OVERHEAD)
+#define ORINOCO_MAX_MTU		(IEEE80211_DATA_LEN - ENCAPS_OVERHEAD)
 
 #define SYMBOL_MAX_VER_LEN	(14)
 #define USER_BAP		0
@@ -735,7 +736,7 @@
 	if ( (new_mtu < ORINOCO_MIN_MTU) || (new_mtu > ORINOCO_MAX_MTU) )
 		return -EINVAL;
 
-	if ( (new_mtu + ENCAPS_OVERHEAD + IEEE802_11_HLEN) >
+	if ( (new_mtu + ENCAPS_OVERHEAD + IEEE80211_HLEN) >
 	     (priv->nicbuf_size - ETH_HLEN) )
 		return -EINVAL;
 
@@ -1074,7 +1075,7 @@
 		stats->rx_dropped++;
 		goto drop;
 	}
-	if (length > IEEE802_11_DATA_LEN) {
+	if (length > IEEE80211_DATA_LEN) {
 		printk(KERN_WARNING "%s: Oversized frame received (%d bytes)\n",
 		       dev->name, length);
 		stats->rx_length_errors++;
@@ -2178,7 +2179,7 @@
 
 	/* No need to lock, the hw_unavailable flag is already set in
 	 * alloc_orinocodev() */
-	priv->nicbuf_size = IEEE802_11_FRAME_LEN + ETH_HLEN;
+	priv->nicbuf_size = IEEE80211_FRAME_LEN + ETH_HLEN;
 
 	/* Initialize the firmware */
 	err = hermes_init(hw);
diff -Nru a/drivers/net/wireless/todo.txt b/drivers/net/wireless/todo.txt
--- a/drivers/net/wireless/todo.txt	2005-02-13 19:18:22 -05:00
+++ b/drivers/net/wireless/todo.txt	2005-02-13 19:18:22 -05:00
@@ -7,9 +7,11 @@
 2) Bring new Wireless LAN driver not yet in the kernel there
 	See my web page for details
 	In particular : HostAP
+	In progress.
 
 3) Misc
 	o Mark wavelan, wavelan_cs, netwave_cs drivers as obsolete
 	o Maybe arlan.c, ray_cs.c and strip.c also deserve to be obsolete
+	Completed.
 
 	Jean II
diff -Nru a/drivers/net/wireless/wl3501.h b/drivers/net/wireless/wl3501.h
--- a/drivers/net/wireless/wl3501.h	2005-02-13 19:18:22 -05:00
+++ b/drivers/net/wireless/wl3501.h	2005-02-13 19:18:22 -05:00
@@ -2,7 +2,7 @@
 #define __WL3501_H__
 
 #include <linux/spinlock.h>
-#include "ieee802_11.h"
+#include <net/ieee80211.h>
 
 /* define for WLA 2.0 */
 #define WL3501_BLKSZ 256
@@ -548,7 +548,7 @@
 
 struct wl3501_80211_tx_hdr {
 	struct wl3501_80211_tx_plcp_hdr	pclp_hdr;
-	struct ieee802_11_hdr		mac_hdr;
+	struct ieee80211_hdr		mac_hdr;
 } __attribute__ ((packed));
 
 /*
