From: =?UTF-8?q?Pavel=20=C5=A0imerda?= <pavlix@pavlix.net>
Subject: [PATCH iproute2 2/3] ip-link: fix and extend documentation
Date: Wed, 12 Aug 2015 22:04:07 +0200
Message-ID: <1439409848-26464-2-git-send-email-pavlix@pavlix.net>
References: <1439409848-26464-1-git-send-email-pavlix@pavlix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Vadim Kochan <vadim4j@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Phil Sutter <psutter@redhat.com>,
	=?UTF-8?q?Pavel=20=C5=A0imerda?= <psimerda@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fox.pavlix.net ([84.246.161.104]:46384 "EHLO fox.pavlix.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790AbbHLUIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2015 16:08:49 -0400
In-Reply-To: <1439409848-26464-1-git-send-email-pavlix@pavlix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Pavel =C5=A0imerda <psimerda@redhat.com>

 * Add `can` to list of supported link types
 * Document `addrgenmode`
 * Document `link-netnsid`
 * Document VLAN link type
 * Improve VXLAN link type documentation
    - Fix VXLAN srcport/dstport docs
    - Document `udpcsum`, `udp6zerocsumtx` and `udp6zerocsumrx`
---
 man/man8/ip-link.8.in | 112 ++++++++++++++++++++++++++++++++++++++++++=
++++++--
 1 file changed, 108 insertions(+), 4 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 372e6c6..9ff9a23 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -143,9 +143,13 @@ ip-link \- network device configuration
 ] |
 .br
 .B master
-.IR DEVICE
+.IR DEVICE " |"
 .br
-.B nomaster
+.B nomaster " |"
+.br
+.B addrgenmode { eui64 | none }
+.br
+.B link-netnsid ID
 .BR " }"
=20
=20
@@ -185,6 +189,8 @@ Link types:
 .sp
 .B bond
 - Bonding device
+.B can
+- Controller Area Network interface
 .sp
 .B dummy
 - Dummy network interface
@@ -266,6 +272,66 @@ specifies the number of receive queues for new dev=
ice.
 specifies the desired index of the new virtual device. The link creati=
on fails, if the index is busy.
=20
 .TP
+VLAN Type Support
+For a link of type
+.I VLAN
+the following additional arguments are supported:
+
+.BI "ip link add
+.BI link " DEVICE "
+.BI name " NAME "
+.BI type " vlan "
+.R " [ "
+.BI protocol " VLAN_PROTO "
+.R " ] "
+.BI id " VLANID "
+.R " [ "
+.BR reorder_hdr " { " on " | " off " } "
+.R " ] "
+.R " [ "
+.BR gvrp " { " on " | " off " } "
+.R " ] "
+.R " [ "
+.BR mvrp " { " on " | " off " } "
+.R " ] "
+.R " [ "
+.BR loose_binding " { " on " | " off " } "
+.R " ] "
+.R " [ "
+.BI ingress-qos-map " QOS-MAP "
+.R " ] "
+.R " [ "
+.BI egress-qos-map " QOS-MAP "
+.R " ] "
+
+.in +8
+.sp
+.BI protocol " VLAN_PROTO "
+- either 802.1Q or 802.1ad.
+
+.BI id " VLANID "
+- specifies the VLAN Identifer to use. Note that numbers with a leadin=
g " 0 " or " 0x " are interpreted as octal or hexadeimal, respectively.
+
+.BR reorder_hdr " { " on " | " off " } "
+- specifies whether ethernet headers are reordered or not.
+
+.BR gvrp " { " on " | " off " } "
+- specifies whether this VLAN should be registered using GARP VLAN Reg=
istration Protocol.
+
+.BR mvrp " { " on " | " off " } "
+- specifies whether this VLAN should be registered using Multiple VLAN=
 Registration Protocol.
+
+.BR loose_binding " { " on " | " off " } "
+- specifies whether the VLAN device state is bound to the physical dev=
ice state.
+
+.BI ingress-qos-map " QOS-MAP "
+- defines a mapping between priority code points on incoming frames.  =
The format is FROM:TO with multiple mappings separated by spaces.
+
+.BI egress-qos-map " QOS-MAP "
+- the same as ingress-qos-map but for outgoing frames.
+.in -8
+
+.TP
 VXLAN Type Support
 For a link of type
 .I VXLAN
@@ -284,7 +350,9 @@ the following additional arguments are supported:
 .R " ] [ "
 .BI tos " TOS "
 .R " ] [ "
-.BI port " MIN MAX "
+.BI dstport " PORT "
+.R " ] [ "
+.BI srcport " MIN MAX "
 .R " ] [ "
 .I "[no]learning "
 .R " ] [ "
@@ -296,6 +364,12 @@ the following additional arguments are supported:
 .R " ] [ "
 .I "[no]l3miss "
 .R " ] [ "
+.I "[no]udpcsum "
+.R " ] [ "
+.I "[no]udp6zerocsumtx "
+.R " ] [ "
+.I "[no]udp6zerocsumrx "
+.R " ] [ "
 .BI ageing " SECONDS "
 .R " ] [ "
 .BI maxaddress " NUMBER "
@@ -340,7 +414,11 @@ parameter.
 - specifies the TOS value to use in outgoing packets.
=20
 .sp
-.BI port " MIN MAX"
+.BI dstport " PORT"
+- specifies the UDP destination port to communicate to the remote VXLA=
N tunnel endpoint.
+
+.sp
+.BI srcport " MIN MAX"
 - specifies the range of port numbers to use as UDP
 source ports to communicate to the remote VXLAN tunnel endpoint.
=20
@@ -366,6 +444,18 @@ are entered into the VXLAN device forwarding datab=
ase.
 - specifies if netlink IP ADDR miss notifications are generated.
=20
 .sp
+.I [no]udpcsum
+- specifies if UDP checksum is filled in
+
+.sp
+.I [no]udp6zerocsumtx
+- specifies if UDP checksum is filled in
+
+.sp
+.I [no]udp6zerocsumrx
+- specifies if UDP checksum is received
+
+.sp
 .BI ageing " SECONDS"
 - specifies the lifetime in seconds of FDB entries learnt by the kerne=
l.
=20
@@ -751,6 +841,12 @@ tool can be used. But it allows to change network =
namespace only for physical de
 give the device a symbolic name for easy reference.
=20
 .TP
+.BI group " GROUP"
+specify the group the device belongs to.
+The available groups are listed in file
+.BR "@SYSCONFDIR@/group" .
+
+.TP
 .BI vf " NUM"
 specify a Virtual Function device to be configured. The associated PF =
device
 must be specified using the
@@ -829,6 +925,14 @@ set master device of the device (enslave device).
 .BI nomaster
 unset master device of the device (release device).
=20
+.TP
+.BR "addrgenmode eui64 " or " addrgenmode none"
+set IPv6 address generation mode
+
+.TP
+.BR "link-netnsid "
+set peer netnsid for a cross-netns interface
+
 .PP
 .B Warning:
 If multiple parameter changes are requested,
--=20
2.4.1
