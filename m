From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 04/12] man: Add a man page for the nat action
Date: Fri,  4 Mar 2016 13:11:39 +0100
Message-ID: <1457093507-25601-5-git-send-email-phil@nwl.cc>
References: <1457093507-25601-1-git-send-email-phil@nwl.cc>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:32855 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753504AbcCDMMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 07:12:25 -0500
Received: from mail.nwl.cc (orbyte.nwl.cc [127.0.0.1])
	by mail.nwl.cc (Postfix) with ESMTP id 978316BF3E
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:12:23 +0100 (CET)
Received: from xsao (localhost [IPv6:::1])
	by mail.nwl.cc (Postfix) with ESMTP id 7CB316894E
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:12:23 +0100 (CET)
In-Reply-To: <1457093507-25601-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-nat.8 | 78 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 78 insertions(+)
 create mode 100644 man/man8/tc-nat.8

diff --git a/man/man8/tc-nat.8 b/man/man8/tc-nat.8
new file mode 100644
index 0000000000000..fdcc052a4bca4
--- /dev/null
+++ b/man/man8/tc-nat.8
@@ -0,0 +1,78 @@
+.TH "NAT action in tc" 8 "12 Jan 2015" "iproute2" "Linux"
+
+.SH NAME
+nat - stateless native address translation action
+.SH SYNOPSIS
+.in +8
+.ti -8
+.BR tc " ... " "action nat"
+.I DIRECTION OLD NEW
+
+.ti -8
+.IR DIRECTION " := { "
+.BR ingress " | " egress " }"
+
+.ti -8
+.IR OLD " := " IPV4_ADDR_SPEC
+
+.ti -8
+.IR NEW " := " IPV4_ADDR_SPEC
+
+.ti -8
+.IR IPV4_ADDR_SPEC " := { "
+.BR default " | " any " | " all " | "
+\fIin_addr\fR[\fB/\fR{\fIprefix\fR|\fInetmask\fR}]
+.SH DESCRIPTION
+The
+.B nat
+action allows to perform NAT without the overhead of conntrack, which is
+desirable if the number of flows or addresses to perform NAT on is large. This
+action is best used in combination with the
+.B u32
+filter to allow for efficient lookups of a large number of stateless NAT rules
+in constant time.
+.SH OPTIONS
+.TP
+.B ingress
+Translate destination addresses, i.e. perform DNAT.
+.TP
+.B egress
+Translate source addresses, i.e. perform SNAT.
+.TP
+.I OLD
+Specifies addresses which should be translated.
+.TP
+.I NEW
+Specifies addresses which
+.I OLD
+should be translated into.
+.SH NOTES
+The accepted address format in
+.IR OLD " and " NEW
+is quite flexible. It may either consist of one of the keywords
+.BR default ", " any " or " all ,
+representing the all-zero IP address or a combination of IP address and netmask
+or prefix length separated by a slash
+.RB ( / )
+sign. In any case, the mask (or prefix length) value of
+.I OLD
+is used for
+.I NEW
+as well so that a one-to-one mapping of addresses is assured.
+
+Address translation is done using a combination of binary operations. First, the
+original (source or destination) address is matched against the value of
+.IR OLD .
+If the original address fits, the new address is created by taking the leading
+bits from
+.I NEW
+(defined by the netmask of
+.IR OLD )
+and taking the remaining bits from the original address.
+
+There is rudimental support for upper layer protocols, namely TCP, UDP and ICMP.
+While for the first two only checksum recalculation is performed, the action
+also takes care of embedded IP headers in ICMP packets by translating the
+respective address therein, too.
+.SH SEE ALSO
+.BR tc (8)
-- 
2.7.2
