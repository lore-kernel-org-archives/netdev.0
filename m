From: Dmitry Kozlov <xeb@mail.ru>
Subject: [PATCH] iproute2: ip6gre: update man pages
Date: Tue, 1 Oct 2013 11:18:34 +0400
Message-ID: <20131001111834.56f34d28@dima>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback1.mail.ru ([94.100.176.18]:33328 "EHLO
	fallback1.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326Ab3JAHTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 03:19:04 -0400
Received: from smtp40.i.mail.ru (smtp40.i.mail.ru [94.100.177.100])
	by fallback1.mail.ru (mPOP.Fallback_MX) with ESMTP id 0016E29D6468
	for <netdev@vger.kernel.org>; Tue,  1 Oct 2013 11:19:01 +0400 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update man pages with ip6gre info.

Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
---
 man/man8/ip-link.8.in | 124 +++++++++++++++++++++++++++++++++++++++++++++++++-
 man/man8/ip-tunnel.8  |   4 +-
 2 files changed, 125 insertions(+), 3 deletions(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 76f92dd..8b68c78 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -62,7 +62,11 @@ ip-link \- network device configuration
 .BR vxlan " |"
 .BR ip6tnl " |"
 .BR ipip " |"
-.BR sit " ]"
+.BR sit " |"
+.BR gre " |"
+.BR gretap " |"
+.BR ip6gre " |"
+.BR ip6gretap " ]"
 
 .ti -8
 .BI "ip link delete " DEVICE
@@ -186,6 +190,18 @@ Link types:
 .sp
 .BR sit
 - Virtual tunnel interface IPv6 over IPv4
+.sp
+.BR gre
+- Virtual tunnel interface GRE over IPv4
+.sp
+.BR gretap
+- Virtual L2 tuunel interface GRE over IPv4
+.sp
+.BR ip6gre
+- Virtual tuunel interface GRE over IPv6
+.sp
+.BR ip6gretap
+- Virtual L2 tuunel interface GRE over IPv6
 .in -8
 
 .TP
@@ -292,6 +308,112 @@ are entered into the VXLAN device forwarding database.
 
 .in -8
 
+.TP
+IP6GRE/IP6GRETAP Type Support
+For a link of type 
+.I IP6GRE/IP6GRETAP
+the following additional arguments are supported:
+
+.BI "ip link add " DEVICE
+.BI type " { ip6gre | ip6gretap }  " remote " ADDR " local " ADDR
+.R " [ "
+.I "[i|o]seq]"
+.R " ] [ "
+.I "[i|o]key" KEY
+.R " ] [ "
+.I " [i|o]csum "
+.R " ] [ "
+.BI hoplimit " TTL "
+.R " ] [ "
+.BI encaplimit " ELIM "
+.R " ] [ "
+.BI tclass " TCLASS "
+.R " ] [ "
+.BI flowlabel " FLOWLABEL "
+.R " ] [ "
+.BI "dscp inherit"
+.R " ] [ "
+.BI dev " PHYS_DEV "
+.R " ]"
+
+.in +8
+.sp
+.BI  remote " ADDR "
+- specifies the remote IPv6 address of the tunnel.
+
+.sp
+.BI  local " ADDR "
+- specifies the fixed local IPv6 address for tunneled packets.
+It must be and address on another interface on this host.
+
+.sp
+.BI  [i|o]seq
+- serialize packets.
+The
+.B oseq
+flag enables sequencing of outgoing packets.
+The
+.B iseq
+flag requires that all input packets are serialized.
+
+.sp
+.BI  [i|o]key " KEY"
+- use keyed GRE with key
+.IR KEY ". "KEY
+is either a number or an IPv4 address-like dotted quad.
+The
+.B key
+parameter specifies the same key to use in both directions.
+The
+.BR ikey " and " okey
+parameters specify different keys for input and output.
+
+.sp
+.BI  [i|o]csum
+- generate/require checksums for tunneled packets.
+The
+.B ocsum
+flag calculates checksums for outgoing packets.
+The
+.B icsum
+flag requires that all input packets have the correct
+checksum.  The
+.B csum
+flag is equivalent to the combination
+.BR "icsum ocsum" .
+
+.sp
+.BI  hoplimit " TTL"
+- specifies Hop Limit value to use in outgoing packets.
+
+.sp
+.BI  encaplimit " ELIM"
+- specifies a fixed encapsulation limit.  Default is 4.
+
+.sp
+.BI  flowlabel " FLOWLABEL"
+- specifies a fixed flowlabel. 
+
+.sp
+.BI  tclass " TCLASS"
+- specifies the traffic class field on
+tunneled packets, which can be specified as either a two-digit
+hex value (e.g. c0) or a predefined string (e.g. internet).
+The value
+.B inherit
+causes the field to be copied from the original IP header. The
+values
+.BI "inherit/" STRING
+or
+.BI "inherit/" 00 ".." ff
+will set the field to
+.I STRING
+or
+.IR 00 ".." ff
+when tunneling non-IP packets. The default value is 00.
+
+.in -8
+
 .SS ip link delete - delete virtual link
 .I DEVICE
 specifies the virtual  device to act operate on.
diff --git a/man/man8/ip-tunnel.8 b/man/man8/ip-tunnel.8
index 697e80d..fc2d6bd 100644
--- a/man/man8/ip-tunnel.8
+++ b/man/man8/ip-tunnel.8
@@ -50,7 +50,7 @@ ip-tunnel - tunnel configuration
 
 .ti -8
 .IR MODE " := "
-.RB " { " ipip " | " gre " | " sit " | " isatap " | " ip6ip6 " | " ipip6 " | " any " }"
+.RB " { " ipip " | " gre " | " sit " | " isatap " | " ip6ip6 " | " ipip6 " | " ip6gre " | " any " }"
 
 .ti -8
 .IR ADDR " := { " IP_ADDRESS " |"
@@ -110,7 +110,7 @@ Modes for IPv4 encapsulation available:
 .BR ipip ", " sit ", " isatap " and " gre "."
 .br
 Modes for IPv6 encapsulation available:
-.BR ip6ip6 ", " ipip6 " and " any "."
+.BR ip6ip6 ", " ipip6 ", " ip6gre ", and " any "."
 
 .TP
 .BI remote " ADDRESS"
-- 
1.8.3.2
