From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH ethtool 3/3] Documentation for IPv6 NFC
Date: Mon, 15 Feb 2016 15:00:10 +0000
Message-ID: <56C1E7FA.6050601@solarflare.com>
References: <56C1E73A.5090603@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Ben Hutchings <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:47049 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753394AbcBOPAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 10:00:18 -0500
In-Reply-To: <56C1E73A.5090603@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Leaves 'src-ip' and 'dst-ip' documented as taking x.x.x.x, because there's
more low-level nroff here than I can parse, let alone emit.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 ethtool.8.in | 34 +++++++++++++++++++++++++---------
 ethtool.c    |  4 +++-
 2 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index eeffa70..5c0a9e3 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -74,7 +74,7 @@
 .\"
 .\"	\(*NC - Network Classifier type values
 .\"
-.ds NC \fBether\fP|\fBip4\fP|\fBtcp4\fP|\fBudp4\fP|\fBsctp4\fP|\fBah4\fP|\fBesp4\fP
+.ds NC \fBether\fP|\fBip4\fP|\fBip6\fP|\fBtcp4\fP|\fBudp4\fP|\fBsctp4\fP|\fBah4\fP|\fBesp4\fP|\fBtcp6\fP|\fBudp6\fP|\fBah6\fP|\fBesp6\fP|\fBsctp6\fP
 ..
 .\"
 .\" Start URL.
@@ -260,6 +260,8 @@ ethtool \- query or control network driver and hardware settings
 .RB [ src\-ip \ \*(PA\ [ m \ \*(PA]]
 .RB [ dst\-ip \ \*(PA\ [ m \ \*(PA]]
 .BM tos
+.BM tclass
+.BM nexthdr
 .BM l4proto
 .BM src\-port
 .BM dst\-port
@@ -676,11 +678,17 @@ nokeep;
 lB	l.
 ether	Ethernet
 ip4	Raw IPv4
+ip6	Raw IPv6
 tcp4	TCP over IPv4
 udp4	UDP over IPv4
 sctp4	SCTP over IPv4
 ah4	IPSEC AH over IPv4
 esp4	IPSEC ESP over IPv4
+tcp6	TCP over IPv6
+udp6	UDP over IPv6
+sctp6	SCTP over IPv6
+ah6	IPSEC AH over IPv6
+esp6	IPSEC ESP over IPv6
 .TE
 .PP
 For all fields that allow both a value and a mask to be specified, the
@@ -706,38 +714,46 @@ Valid only for flow-type ether.
 .TP
 .BR src\-ip \ \*(PA\ [ m \ \*(PA]
 Specify the source IP address of the incoming packet to match along with
-an optional mask.  Valid for all IPv4 based flow-types.
+an optional mask.  Valid for all IP based flow-types.
 .TP
 .BR dst\-ip \ \*(PA\ [ m \ \*(PA]
 Specify the destination IP address of the incoming packet to match along
-with an optional mask.  Valid for all IPv4 based flow-types.
+with an optional mask.  Valid for all IP based flow-types.
 .TP
 .BI tos \ N \\fR\ [\\fPm \ N \\fR]\\fP
 Specify the value of the Type of Service field in the incoming packet to
 match along with an optional mask.  Applies to all IPv4 based flow-types.
 .TP
+.BI tclass \ N \\fR\ [\\fPm \ N \\fR]\\fP
+Specify the value of the Traffic Class field in the incoming packet to
+match along with an optional mask.  Applies to all IPv6 based flow-types.
+.TP
+.BI nexthdr \ N \\fR\ [\\fPm \ N \\fR]\\fP
+Includes the IPv6 Next Header and optional mask.  Valid only for flow-type
+ip6.
+.TP
 .BI l4proto \ N \\fR\ [\\fPm \ N \\fR]\\fP
 Includes the layer 4 protocol number and optional mask.  Valid only for
-flow-type ip4.
+flow-types ip4 and ip6.
 .TP
 .BI src\-port \ N \\fR\ [\\fPm \ N \\fR]\\fP
 Specify the value of the source port field (applicable to TCP/UDP packets)
 in the incoming packet to match along with an optional mask.  Valid for
-flow-types ip4, tcp4, udp4, and sctp4.
+flow-types ip4, tcp4, udp4, and sctp4 and their IPv6 equivalents.
 .TP
 .BI dst\-port \ N \\fR\ [\\fPm \ N \\fR]\\fP
 Specify the value of the destination port field (applicable to TCP/UDP
 packets)in the incoming packet to match along with an optional mask.
-Valid for flow-types ip4, tcp4, udp4, and sctp4.
+Valid for flow-types ip4, tcp4, udp4, and sctp4 and their IPv6 equivalents.
 .TP
 .BI spi \ N \\fR\ [\\fPm \ N \\fR]\\fP
 Specify the value of the security parameter index field (applicable to
 AH/ESP packets)in the incoming packet to match along with an optional
-mask.  Valid for flow-types ip4, ah4, and esp4.
+mask.  Valid for flow-types ip4, ah4, and esp4 and their IPv6 equivalents.
 .TP
 .BI l4data \ N \\fR\ [\\fPm \ N \\fR]\\fP
 Specify the value of the first 4 Bytes of Layer 4 in the incoming packet to
-match along with an optional mask.  Valid for ip4 flow-type.
+match along with an optional mask.  Valid for ip4 and ip6 flow-types.
 .TP
 .BI vlan\-etype \ N \\fR\ [\\fPm \ N \\fR]\\fP
 Includes the VLAN tag Ethertype and an optional mask.
@@ -751,7 +767,7 @@ Includes 64-bits of user-specific data and an optional mask.
 .BR dst-mac \ \*(MA\ [ m \ \*(MA]
 Includes the destination MAC address, specified as 6 bytes in hexadecimal
 separated by colons, along with an optional mask.
-Valid for all IPv4 based flow-types.
+Valid for all IP based flow-types.
 .TP
 .BI action \ N
 Specifies the Rx queue to send packets to, or some other action.
diff --git a/ethtool.c b/ethtool.c
index f18ad73..b1de453 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4108,13 +4108,15 @@ static const struct option {
 	  "Configure Rx network flow classification options or rules",
 	  "		rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
 	  "tcp6|udp6|ah6|esp6|sctp6 m|v|t|s|d|f|n|r... |\n"
-	  "		flow-type ether|ip4|tcp4|udp4|sctp4|ah4|esp4\n"
+	  "		flow-type ether|ip4|tcp4|udp4|sctp4|ah4|esp4|"
+	  "ip6|tcp6|udp6|ah6|esp6|sctp6\n"
 	  "			[ src %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
 	  "			[ dst %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
 	  "			[ proto %d [m %x] ]\n"
 	  "			[ src-ip %d.%d.%d.%d [m %d.%d.%d.%d] ]\n"
 	  "			[ dst-ip %d.%d.%d.%d [m %d.%d.%d.%d] ]\n"
 	  "			[ tos %d [m %x] ]\n"
+	  "			[ tclass %d [m %x] ]\n"
 	  "			[ l4proto %d [m %x] ]\n"
 	  "			[ src-port %d [m %x] ]\n"
 	  "			[ dst-port %d [m %x] ]\n"
