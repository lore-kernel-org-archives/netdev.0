From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [IPROUTE2 PATCH 2/2]: Add missing description about ISATAP and
 IPv6 tunnels in ip(8) manpage.
Date: Thu, 13 Mar 2008 11:19:00 -0400 (EDT)
Message-ID: <20080313.111900.81015265.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54035 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752371AbYCMPRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 11:17:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 7dae5af..1430384 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -278,9 +278,9 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .BR "ip tunnel" " { " add " | " change " | " del " | " show " }"
 .RI "[ " NAME " ]"
 .br
-.RB "[ " mode " { " ipip " | " gre " | " sit " } ]"
-.br
-.RB "[ " remote
+.RB "[ " mode
+.IR MODE " ] [ "
+.B remote
 .IR ADDR " ] [ "
 .B  local
 .IR ADDR " ]"
@@ -289,14 +289,24 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .IR KEY " ] [ "
 .RB "[" i "|" o "]" csum " ] ]"
 .br
+.RB "[ " encaplimit
+.IR ELIM " ]"
 .RB "[ " ttl
-.IR TTL " ] [ "
-.B  tos
+.IR TTL " ]"
+.br
+.RB "[ " tos
 .IR TOS " ] [ "
-.RB "[" no "]" pmtudisc " ]"
+.B flowlabel
+.IR FLOWLABEL " ]"
 .br
+.RB "[ [" no "]" pmtudisc " ]"
 .RB "[ " dev
 .IR PHYS_DEV " ]"
+.RB "[ " "dscp inherit" " ]"
+
+.ti -8
+.IR MODE " := "
+.RB " { " ipip " | " gre " | " sit " | " isatap " | " ip6ip6 " | " ipip6 " | " any " }"
 
 .ti -8
 .IR ADDR " := { " IP_ADDRESS " |"
@@ -307,6 +317,12 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .BR inherit " }"
 
 .ti -8
+.IR ELIM " := { 
+.BR none " | "
+.IR 0 ".." 255 " }"
+
+.ti -8
+.ti -8
 .IR TTL " := { " 1 ".." 255 " | "
 .BR inherit " }"
 
@@ -1706,8 +1722,11 @@ the prefix selecting the IP source addresses of the multicast route.
 
 .SH ip tunnel - tunnel configuration
 .B tunnel
-objects are tunnels, encapsulating packets in IPv4 packets and then
+objects are tunnels, encapsulating packets in IP packets and then
 sending them over the IP infrastructure.
+The encapulating (or outer) address family is specified by the
+.B -f
+option.  The default is IPv4.
 
 .SS ip tunnel add - add a new tunnel
 .SS ip tunnel change - change an existing tunnel
@@ -1719,8 +1738,13 @@ select the tunnel device name.
 
 .TP
 .BI mode " MODE"
-set the tunnel mode.  Three modes are currently available:
-.BR ipip ", " sit " and " gre "."
+set the tunnel mode. Available modes depend on the encapsulating address family.
+.br
+Modes for IPv4 encapsulation available:
+.BR ipip ", " sit ", " isatap " and " gre "."
+.br
+Modes for IPv6 encapsulation available:
+.BR ip6ip6 ", " ipip6 " and " any "."
 
 .TP
 .BI remote " ADDRESS"
@@ -1739,14 +1763,19 @@ on tunneled packets.
 .I N
 is a number in the range 1--255. 0 is a special value
 meaning that packets inherit the TTL value. 
-The default value is:
+The default value for IPv4 tunnels is:
 .BR "inherit" .
+The default value for IPv6 tunnels is:
+.BR "64" .
+
 
 .TP
 .BI tos " T"
 .TP
 .BI dsfield " T"
-set a fixed TOS
+.TP
+.BI tclass " T"
+set a fixed TOS (or traffic class in IPv6)
 .I T
 on tunneled packets.
 The default value is:
@@ -1815,6 +1844,24 @@ flag is equivalent to the combination
 .BR "iseq oseq" .
 .B It isn't work. Don't use it.
 
+.TP
+.RP
+.BI dscp inherit
+.RB ( " only IPv6 tunnels " )
+Inherit DS field between inner and outer header.
+
+.TP
+.RP
+.BI encaplim " ELIM"
+.RB ( " only IPv6 tunnels " )
+set a fixed encapsulation limit.  Default is 4.
+
+.TP
+.RP
+.BI flowlabel " FLOWLABEL"
+.RB ( " only IPv6 tunnels " )
+set a fixed flowlabel.
+
 .SS ip tunnel show - list tunnels
 This command has no arguments.
 

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
