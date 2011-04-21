From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 6/6] Update documentation for -u/-U operations
Date: Thu, 21 Apr 2011 13:40:45 -0700
Message-ID: <20110421204045.23054.12548.stgit@gitlad.jf.intel.com>
References: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:41385 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754601Ab1DUUkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 16:40:47 -0400
In-Reply-To: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the documentation for the -u/-U operations to include
the recent changes made to support addition/deletion/display of network
flow classifier rules.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 ethtool.8.in |  185 +++++++++++++++++++++++++++++-----------------------------
 ethtool.c    |   32 ++++++----
 2 files changed, 111 insertions(+), 106 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 12a1d1d..8908351 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -42,10 +42,20 @@
 [\\fB\\$1\\fP\ \\fIN\\fP]
 ..
 .\"
+.\"	.BM - same as above but has a mask field for format "[value N [value-mask N]]"
+.\"
+.de BM
+[\\fB\\$1\\fP\ \\fIN\\fP\ [\\fB\\$1\-mask\\fP\ \\fIN\\fP]]
+..
+.\"
 .\"	\(*MA - mac address
 .\"
 .ds MA \fIxx\fP\fB:\fP\fIyy\fP\fB:\fP\fIzz\fP\fB:\fP\fIaa\fP\fB:\fP\fIbb\fP\fB:\fP\fIcc\fP
 .\"
+.\"	\(*PA - IP address
+.\"
+.ds PA \fIx\fP\fB.\fP\fIx\fP\fB.\fP\fIx\fP\fB.\fP\fIx\fP
+.\"
 .\"	\(*WO - wol flags
 .\"
 .ds WO \fBp\fP|\fBu\fP|\fBm\fP|\fBb\fP|\fBa\fP|\fBg\fP|\fBs\fP|\fBd\fP...
@@ -57,6 +67,12 @@
 .\"	\(*HO - hash options
 .\"
 .ds HO \fBm\fP|\fBv\fP|\fBt\fP|\fBs\fP|\fBd\fP|\fBf\fP|\fBn\fP|\fBr\fP...
+.\"
+.\"	\(*NC - Network Classifier type values
+.\"
+.ds NC \fBether\fP|\fBip4\fP|\fBtcp4\fP|\fBudp4\fP|\fBsctp4\fP|\fBah4\fP|\fBesp4\fP
+
+.\"
 .\" Start URL.
 .de UR
 .  ds m1 \\$1\"
@@ -236,9 +252,9 @@ ethtool \- query or control network driver and hardware settings
 .HP
 .B ethtool \-N
 .I ethX
-.RB [ rx\-flow\-hash \ \*(FL
-.RB \ \*(HO]
+.RB [ rx-flow-hash \ \*(FL \  \*(HO]
 .HP
+
 .B ethtool \-x|\-\-show\-rxfh\-indir
 .I ethX
 .HP
@@ -257,54 +273,28 @@ ethtool \- query or control network driver and hardware settings
 .HP
 .B ethtool \-u|\-\-show\-ntuple
 .I ethX
-.TP
+.BN class-rule
+.HP
+
 .BI ethtool\ \-U|\-\-config\-ntuple \ ethX
-.RB {
-.A3 flow\-type tcp4 udp4 sctp4
-.RB [ src\-ip
-.IR addr
-.RB [ src\-ip\-mask
-.IR mask ]]
-.RB [ dst\-ip
-.IR addr
-.RB [ dst\-ip\-mask
-.IR mask ]]
-.RB [ src\-port
-.IR port
-.RB [ src\-port\-mask
-.IR mask ]]
-.RB [ dst\-port
-.IR port
-.RB [ dst\-port\-mask
-.IR mask ]]
-.br
-.RB | \ flow\-type\ ether
-.RB [ src
-.IR mac\-addr
-.RB [ src\-mask
-.IR mask ]]
-.RB [ dst
-.IR mac\-addr
-.RB [ dst\-mask
-.IR mask ]]
-.RB [ proto
-.IR N
-.RB [ proto\-mask
-.IR mask ]]\ }
-.br
-.RB [ vlan
-.IR VLAN\-tag
-.RB [ vlan\-mask
-.IR mask ]]
-.RB [ user\-def
-.IR data
-.RB [ user\-def\-mask
-.IR mask ]]
-.RI action \ N
-.
-.\" Adjust lines (i.e. full justification) and hyphenate.
-.ad
-.hy
+.BN class-rule-del
+.RB [\  flow-type \ \*(NC
+.RB [ src \ \*(MA\ [ src-mask \ \*(MA]]
+.RB [ dst \ \*(MA\ [ dst-mask \ \*(MA]]
+.BM proto
+.RB [ src-ip \ \*(PA\ [ src-ip-mask \ \*(PA]]
+.RB [ dst-ip \ \*(PA\ [ dst-ip-mask \ \*(PA]]
+.BM tos
+.BM l4proto
+.BM src-port
+.BM dst-port
+.BM spi
+.BM vlan-etype
+.BM vlan
+.BM user-def
+.BN action
+.BN loc
+.RB ]
 
 .SH DESCRIPTION
 .BI ethtool
@@ -630,12 +620,18 @@ Default region is 0 which denotes all regions in the flash.
 .TP
 .B \-u \-\-show\-ntuple
 Get Rx ntuple filters and actions, then display them to the user.
+.TP
+.BI class-rule \ N
+Retrieves the RX classification rule with the given ID.
 .PD
 .RE
 .TP
 .B \-U \-\-config\-ntuple
 Configure Rx ntuple filters and actions
 .TP
+.BI class-rule-del \ N
+Deletes the RX classification rule with the given ID.
+.TP
 .B flow\-type tcp4|udp4|sctp4|ether
 .TS
 nokeep;
@@ -643,64 +639,61 @@ lB	l.
 tcp4	TCP over IPv4
 udp4	UDP over IPv4
 sctp4	SCTP over IPv4
+ah4	IPSEC AH over IPv4
+esp4	IPSEC ESP over IPv4
+ip4	Raw IPv4
 ether	Ethernet
 .TE
 .TP
-.BI src\-ip \ addr
-Includes the source IP address, specified using dotted-quad notation
-or as a single 32-bit number.
-.TP
-.BI src\-ip\-mask \ mask
-Specify a mask for the source IP address.
-.TP
-.BI dst\-ip \ addr
-Includes the destination IP address.
-.TP
-.BI dst\-ip\-mask \ mask
-Specify a mask for the destination IP address.
-.TP
-.BI src\-port \ port
-Includes the source port.
-.TP
-.BI src\-port\-mask \ mask
-Specify a mask for the source port.
+.BR src \ \*(MA\ [ src-mask \ \*(MA]
+Includes the source MAC address, specified as 6 bytes in hexadecimal
+separated by colons, along with an optional mask.
 .TP
-.BI dst\-port \ port
-Includes the destination port.
+.BR dst \ \*(MA\ [ src-mask \ \*(MA]
+Includes the destination MAC address, specified as 6 bytes in hexadecimal
+separated by colons, along with an optional mask.
 .TP
-.BI dst\-port\-mask \ mask
-Specify a mask for the destination port.
+.BI proto \ N \\fR\ [\\fPproto-mask \ N \\fR]\\fP
+Includes the Ethernet protocol number (ethertype) and an optional mask.
 .TP
-.BI src \ mac\-addr
-Includes the source MAC address, specified as 6 bytes in hexadecimal
-separated by colons.
+.BR src-ip \ \*(PA\ [ src-ip-mask \ \*(PA]
+Specify the source IP address of the incoming packet to
+match along with an optional mask.
 .TP
-.BI src\-mask \ mask
-Specify a mask for the source MAC address.
+.BR dst-ip \ \*(PA\ [ dst-ip-mask \ \*(PA]
+Specify the destination IP address of the incoming packet to
+match along with an optional mask.
 .TP
-.BI dst \ mac\-addr
-Includes the destination MAC address.
+.BI tos \ N \\fR\ [\\fPtos-mask \ N \\fR]\\fP
+Specify the value of the Type of Service field in the incoming packet to
+match along with an optional mask.
 .TP
-.BI dst\-mask \ mask
-Specify a mask for the destination MAC address.
+.BI l4proto \ N \\fR\ [\\fPl4proto-mask \ N \\fR]\\fP
+Includes the layer 4 protocol number and optional mask.
 .TP
-.BI proto \ N
-Includes the Ethernet protocol number (ethertype).
+.BI src-port \ N \\fR\ [\\fPsrc-port-mask \ N \\fR]\\fP
+Specify the value of the source port field (applicable to
+TCP/UDP packets)in the incoming packet to match along with an
+optional mask.
 .TP
-.BI proto\-mask \ mask
-Specify a mask for the Ethernet protocol number.
+.BI dst-port \ N \\fR\ [\\fPdst-port-mask \ N \\fR]\\fP
+Specify the value of the destination port field (applicable to
+TCP/UDP packets)in the incoming packet to match along with an
+optional mask.
 .TP
-.BI vlan \ VLAN\-tag
-Includes the VLAN tag.
+.BI spi \ N \\fR\ [\\fPspi-mask \ N \\fR]\\fP
+Specify the value of the security parameter index field (applicable to
+AH/ESP packets)in the incoming packet to match along with an
+optional mask.
 .TP
-.BI vlan\-mask \ mask
-Specify a mask for the VLAN tag.
+.BI vlan-etype \ N \\fR\ [\\fPvlan-etype-mask \ N \\fR]\\fP
+Includes the VLAN tag Ethertype and an optional mask.
 .TP
-.BI user\-def \ data
-Includes 64-bits of user-specific data.
+.BI vlan \ N \\fR\ [\\fPvlan-mask \ N \\fR]\\fP
+Includes the VLAN tag and an optional mask.
 .TP
-.BI user\-def\-mask \ mask
-Specify a mask for the user-specific data.
+.BI user-def \ N \\fR\ [\\fPuser-def-mask \ N \\fR]\\fP
+Includes 64-bits of user-specific data and an optional mask.
 .TP
 .BI action \ N
 Specifies the Rx queue to send packets to, or some other action.
@@ -711,6 +704,11 @@ lB	l.
 -1	Drop the matched flow
 0 or higher	Rx queue to route the flow
 .TE
+.TP
+.BI loc \ N
+Specify the location/ID to insert the rule. This will overwrite
+any rule present in that location and will not go through any
+of the rule ordering process.
 .SH BUGS
 Not supported (in part or whole) on all network drivers.
 .SH AUTHOR
@@ -724,7 +722,8 @@ Jakub Jelinek,
 Andre Majorel,
 Eli Kupermann,
 Scott Feldman,
-Andi Kleen.
+Andi Kleen,
+Alexander Duyck.
 .SH AVAILABILITY
 .B ethtool
 is available from
diff --git a/ethtool.c b/ethtool.c
index 421fe20..e65979d 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -243,20 +243,26 @@ static struct option {
 		"		equal N | weight W0 W1 ...\n" },
     { "-U", "--config-ntuple", MODE_SCLSRULE, "Configure Rx ntuple filters "
 		"and actions",
-		"		{ flow-type tcp4|udp4|sctp4\n"
-		"		  [ src-ip ADDR [src-ip-mask MASK] ]\n"
-		"		  [ dst-ip ADDR [dst-ip-mask MASK] ]\n"
-		"		  [ src-port PORT [src-port-mask MASK] ]\n"
-		"		  [ dst-port PORT [dst-port-mask MASK] ]\n"
-		"		| flow-type ether\n"
-		"		  [ src MAC-ADDR [src-mask MASK] ]\n"
-		"		  [ dst MAC-ADDR [dst-mask MASK] ]\n"
-		"		  [ proto N [proto-mask MASK] ] }\n"
-		"		[ vlan VLAN-TAG [vlan-mask MASK] ]\n"
-		"		[ user-def DATA [user-def-mask MASK] ]\n"
-		"		action N\n" },
+		"		[ class-rule-del %d ] |\n"
+		"		[ flow-type ether|ip4|tcp4|udp4|sctp4|ah4|esp4\n"
+		"			[ src %x:%x:%x:%x:%x:%x [src-mask %x:%x:%x:%x:%x:%x] ]\n"
+		"			[ dst %x:%x:%x:%x:%x:%x [dst-mask %x:%x:%x:%x:%x:%x] ]\n"
+		"			[ proto %d [proto-mask MASK] ]\n"
+		"			[ src-ip %d.%d.%d.%d [src-ip-mask %d.%d.%d.%d] ]\n"
+		"			[ dst-ip %d.%d.%d.%d [dst-ip-mask %d.%d.%d.%d] ]\n"
+		"			[ tos %d [tos-mask %x] ]\n"
+		"			[ l4proto %d [l4proto-mask MASK] ]\n"
+		"			[ src-port %d [src-port-mask %x] ]\n"
+		"			[ dst-port %d [dst-port-mask %x] ]\n"
+		"			[ spi %d [spi-mask %x] ]\n"
+		"			[ vlan-etype %x [vlan-etype-mask %x] ]\n"
+		"			[ vlan %x [vlan-mask %x] ]\n"
+		"			[ user-def %x [user-def-mask %x] ]\n"
+		"			[ action %d ]\n"
+		"			[ loc %d]]\n" },
     { "-u", "--show-ntuple", MODE_GCLSRULE,
-		"Get Rx ntuple filters and actions\n" },
+		"Get Rx ntuple filters and actions",
+		"		[ class-rule %d ]\n"},
     { "-P", "--show-permaddr", MODE_PERMADDR,
 		"Show permanent hardware address" },
     { "-h", "--help", MODE_HELP, "Show this help" },

