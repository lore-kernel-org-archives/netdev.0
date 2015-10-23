From: Phil Sutter <phil@nwl.cc>
Subject: [iproute RFC PATCH 4/9] tc: add a man page for flower filter
Date: Fri, 23 Oct 2015 19:47:11 +0200
Message-ID: <1445622436-6386-5-git-send-email-phil@nwl.cc>
References: <1445622436-6386-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:49769 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932272AbbJWRrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 13:47:19 -0400
In-Reply-To: <1445622436-6386-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-flower.8 | 113 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 113 insertions(+)
 create mode 100644 man/man8/tc-flower.8

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
new file mode 100644
index 0000000..df4d8e1
--- /dev/null
+++ b/man/man8/tc-flower.8
@@ -0,0 +1,113 @@
+.TH "Flower filter in tc" 8 "22 Oct 2015" "iproute2" "Linux"
+
+.SH NAME
+flower \- flow based traffic control filter
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR tc " " filter " ... " flower " [ "
+.IR MATCH_LIST " ] [ "
+.B action
+.IR ACTION_SPEC " ] [ "
+.B classid
+.IR CLASSID " ]"
+
+.ti -8
+.IR MATCH_LIST " := [ " MATCH_LIST " ] " MATCH
+
+.ti -8
+.IR MATCH " := { "
+.B indev
+.IR ifname " | { "
+.BR dst_mac " | " src_mac " } "
+.IR mac_address " | "
+.BR eth_type " { " ipv4 " | " ipv6 " | "
+.IR ETH_TYPE " } | "
+.BR ip_proto " { " tcp " | " udp " | "
+.IR IP_PROTO " } | { "
+.BR dst_ip " | " src_ip " } { "
+.IR ipv4_address " | " ipv6_address " } | { "
+.BR dst_port " | " src_port " } "
+.IR port_number " }"
+.SH DESCRIPTION
+The
+.B flower
+filter matches flows to the set of keys specified and assigns an arbitrarily
+chosen class ID to packets belonging to them. Additionally (or alternatively) an
+action from the generic action framework may be called.
+.SH OPTIONS
+.TP
+.BI action " ACTION_SPEC"
+Apply an action from the generic actions framework on matching packets.
+.TP
+.BI classid " CLASSID"
+Specify a class to pass matching packets on to.
+.I CLASSID
+is in the form
+.BR X : Y ", while " X " and " Y
+are interpreted as numbers in hexadecimal format.
+.TP
+.BI indev " ifname"
+Match on incoming interface name. Obviously this makes sense only for forwarded
+flows.
+.I ifname
+is the name of an interface which must exist at the time of
+.B tc
+invocation.
+.TP
+.BI dst_mac " mac_address"
+.TQ
+.BI src_mac " mac_address"
+Match on source or destination MAC address.
+.TP
+.BI eth_type " ETH_TYPE"
+Match on layer three protocol.
+.I ETH_TYPE
+may be either
+.BR ipv4 , ipv6
+or an unsigned 16bit value in hexadecimal format.
+.TP
+.BI ip_proto " IP_PROTO"
+Match on layer four protocol.
+.I IP_PROTO
+may be either
+.BR tcp , udp
+or an unsigned 8bit value in hexadecimal format.
+.TP
+.BI dst_ip " ADDRESS"
+.TQ
+.BI src_ip " ADDRESS"
+Match on source or destination IP address.
+.I ADDRESS
+must be a valid IPv4 or IPv6 address, depending on
+.BR ether_type ,
+which has to be specified in beforehand.
+.TP
+.BI dst_port " NUMBER"
+.TQ
+.BI src_port " NUMBER"
+Match on layer 4 protocol source or destination port number. Only available for
+.BR ip_proto " values " udp " and " tcp ,
+which has to be specified in beforehand.
+.SH NOTES
+As stated above where applicable, matches of a certain layer implicitly depend
+on the matches of the next lower layer. Precisely, layer one and two matches (
+.BR indev , dst_mac , src_mac " and " eth_type )
+have no dependency, layer three matches (
+.BR ip_proto , dst_ip " and " src_ip )
+require
+.B eth_type
+being set to either
+.BR ipv4 " or " ipv6 ,
+and finally layer four matches (
+.BR dst_port " and " src_port )
+depend on
+.B ip_proto
+being set to either
+.BR tcp " or " udp .
+.P
+There can be only used one mask per one prio. If user needs to specify different
+mask, he has to use different prio.
+.SH SEE ALSO
+.BR tc (8),
+.BR tc-flow (8)
-- 
2.1.2
