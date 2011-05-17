From: Sebastian =?iso-8859-1?Q?P=F6hn?= <s.poehn@stud.hs-esslingen.de>
Subject: [PATCH] ethtool: change spi param on ip4 to l4data
Date: Tue, 17 May 2011 09:40:34 +0200 (CEST)
Message-ID: <32899.80.254.147.148.1305618034.squirrel@webmail.hs-esslingen.de>
Reply-To: s.poehn@stud.hs-esslingen.de
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: sebastian.poehn@belden.com, bhutchings@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.hs-esslingen.de ([134.108.32.78]:35130 "EHLO
	mail.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572Ab1EQHs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 03:48:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is confusing for users if ip4 has a spi field, which results in
l4_4_bytes filtering. Add a new option and remove spi from ip4.

Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>

diff --git a/ethtool.8.in b/ethtool.8.in
index 42d923b..19ba190 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -284,6 +284,7 @@ ethtool \- query or control network driver and
hardware settings
 .RB [ dst\-ip \ \*(PA\ [ m \ \*(PA]]
 .BM tos
 .BM l4proto
+.BM l4data
 .BM src\-port
 .BM dst\-port
 .BM spi
@@ -683,6 +684,10 @@ match along with an optional mask.  Applies to all
IPv4 based flow-types.
 Includes the layer 4 protocol number and optional mask.  Valid only for
 flow-type ip4.
 .TP
+.BI l4data \ N \\fR\ [\\fPm \ N \\fR]\\fP
+Specify the first 4 byte of layer 4 protocol.  Valid only for
+flow-type ip4.
+.TP
 .BI src\-port \ N \\fR\ [\\fPm \ N \\fR]\\fP
 Specify the value of the source port field (applicable to TCP/UDP packets)
 in the incoming packet to match along with an optional mask.  Valid for
@@ -696,7 +701,7 @@ Valid for flow-types ip4, tcp4, udp4, and sctp4.
 .BI spi \ N \\fR\ [\\fPm \ N \\fR]\\fP
 Specify the value of the security parameter index field (applicable to
 AH/ESP packets)in the incoming packet to match along with an optional
-mask.  Valid for flow-types ip4, ah4, and esp4.
+mask.  Valid for flow-types ah4 and esp4.
 .TP
 .BI vlan\-etype \ N \\fR\ [\\fPm \ N \\fR]\\fP
 Includes the VLAN tag Ethertype and an optional mask.
diff --git a/ethtool.c b/ethtool.c
index 0b7ec05..fe12934 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -242,6 +242,7 @@ static struct option {
 		"			[ dst-ip %d.%d.%d.%d [m %d.%d.%d.%d] ]\n"
 		"			[ tos %d [m %x] ]\n"
 		"			[ l4proto %d [m %x] ]\n"
+		"			[ l4data %d [m %x] ]\n"
 		"			[ src-port %d [m %x] ]\n"
 		"			[ dst-port %d [m %x] ]\n"
 		"			[ spi %d [m %x] ]\n"
diff --git a/rxclass.c b/rxclass.c
index ee486f7..7507979 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -541,6 +541,7 @@ typedef enum {
 #define NTUPLE_FLAG_VLAN	0x100
 #define NTUPLE_FLAG_UDEF	0x200
 #define NTUPLE_FLAG_VETH	0x400
+#define NFC_FLAG_L4DATA	0x800

 struct rule_opts {
 	const char	*name;
@@ -622,7 +623,7 @@ static struct rule_opts rule_nfc_usr_ip4[] = {
 	{ "l4proto", OPT_U8, NFC_FLAG_PROTO,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.proto),
 	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip4_spec.proto) },
-	{ "spi", OPT_BE32, NFC_FLAG_SPI,
+	{ "l4data", OPT_BE32, NFC_FLAG_L4DATA,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.l4_4_bytes),
 	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip4_spec.l4_4_bytes) },
 	{ "src-port", OPT_BE16, NFC_FLAG_SPORT,
