From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH iproute2 net-next v2 3/3] man: add documentation for IPv6 SR commands
Date: Sat, 15 Apr 2017 12:17:17 +0200
Message-ID: <20170415101717.18730-4-david.lebrun@uclouvain.be>
References: <20170415101717.18730-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:39946 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752884AbdDOKRQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 06:17:16 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp2.sgsi.ucl.ac.be (Postfix) with ESMTPS id 2A8C467DF7C
        for <netdev@vger.kernel.org>; Sat, 15 Apr 2017 12:17:06 +0200 (CEST)
In-Reply-To: <20170415101717.18730-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds information about seg6 encapsulation in the ip-route
manual, as well as the ip-sr manual page.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 man/man8/ip-route.8.in | 39 +++++++++++++++++++++++++++++++--
 man/man8/ip-sr.8       | 58 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 95 insertions(+), 2 deletions(-)
 create mode 100644 man/man8/ip-sr.8

diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index d2a44ac..c8eb38a 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -176,7 +176,7 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 
 .ti -8
 .IR ENCAP " := [ "
-.IR MPLS " | " IP | " BPF " ] "
+.IR MPLS " | " IP " | " BPF " | " SEG6 " ] "
 
 .ti -8
 .IR ENCAP_MPLS " := "
@@ -197,7 +197,6 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .B  ttl
 .IR TTL " ]"
 
-
 .ti -8
 .IR ENCAP_BPF " := "
 .BR bpf " [ "
@@ -210,6 +209,16 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .B headroom
 .IR SIZE " ]"
 
+.ti -8
+.IR ENCAP_SEG6 " := "
+.B seg6
+.BR mode " [ "
+.BR encap " | " inline " ] "
+.B segs
+.IR SEGMENTS " [ "
+.B hmac
+.IR KEYID " ]"
+
 .SH DESCRIPTION
 .B ip route
 is used to manipulate entries in the kernel routing tables.
@@ -656,6 +665,8 @@ is a string specifying the supported encapsulation type. Namely:
 .BI bpf
 - Execution of BPF program
 .sp
+.BI seg6
+- encapsulation type IPv6 Segment Routing
 
 .in -8
 .I ENCAPHDR
@@ -712,6 +723,25 @@ is a set of encapsulation attributes specific to the
 .in -2
 .sp
 
+.B seg6
+.in +2
+.B mode inline
+- Directly insert Segment Routing Header after IPv6 header
+.sp
+
+.B mode encap
+- Encapsulate packet in an outer IPv6 header with SRH
+.sp
+
+.I SEGMENTS
+- List of comma-separated IPv6 addresses
+.sp
+
+.I KEYID
+- Numerical value in decimal representation. See \fBip-sr\fR(8).
+.in -2
+.sp
+
 .in -8
 
 .TP
@@ -1001,6 +1031,11 @@ ip route add 10.1.1.0/30 encap mpls 200/300 via 10.1.1.1 dev eth0
 .RS 4
 Adds an ipv4 route with mpls encapsulation attributes attached to it.
 .RE
+.PP
+ip -6 route add 2001:db8:1::/64 encap seg6 mode encap segs 2001:db8:42::1,2001:db8:ffff::2 dev eth0
+.RS 4
+Adds an IPv6 route with SRv6 encapsulation and two segments attached.
+.RE
 .SH SEE ALSO
 .br
 .BR ip (8)
diff --git a/man/man8/ip-sr.8 b/man/man8/ip-sr.8
new file mode 100644
index 0000000..6be1cc5
--- /dev/null
+++ b/man/man8/ip-sr.8
@@ -0,0 +1,58 @@
+.TH IP\-SR 8 "14 Apr 2017" "iproute2" "Linux"
+.SH "NAME"
+ip-sr \- IPv6 Segment Routing management
+.SH SYNOPSIS
+.sp
+.ad l
+.in +8
+.ti -8
+.B ip sr
+.RI " { " COMMAND " | "
+.BR help " }"
+.sp
+.ti -8
+
+.ti -8
+.B ip sr hmac show
+
+.ti -8
+.B ip sr hmac set
+.I KEYID ALGO
+
+.ti -8
+.B ip sr tunsrc show
+
+.ti -8
+.B ip sr tunsrc set
+.I ADDRESS
+
+.SH DESCRIPTION
+The \fBip sr\fR command is used to configure IPv6 Segment Routing (SRv6)
+internal parameters.
+.PP
+Those parameters include the mapping between an HMAC key ID and its associated
+hashing algorithm and secret, and the IPv6 address to use as source for encapsulated
+packets.
+.PP
+The \fBip sr hmac set\fR command prompts for a passphrase that will be used as the
+HMAC secret for the corresponding key ID. A blank passphrase removes the mapping.
+The currently supported algorithms for \fIALGO\fR are \fBsha1\fR and \fBsha256\fR.
+.PP
+If the tunnel source is set to the address :: (which is the default), then an address
+of the egress interface will be selected. As this operation may hinder performances,
+it is recommended to set a non-default address.
+
+.SH EXAMPLES
+.PP
+.SS Configure an HMAC mapping for key ID 42 and hashing algorithm SHA-256
+.nf
+# ip sr hmac set 42 sha256
+.PP
+.SS Set the tunnel source address to 2001:db8::1
+.nf
+# ip sr tunsrc set 2001:db8::1
+.SH SEE ALSO
+.br
+.BR ip-route (8)
+.SH AUTHOR
+David Lebrun <david.lebrun@uclouvain.be>
-- 
2.10.2
