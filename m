From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/3] ip-route man: add usage and description for lwtunnel encap attributes
Date: Thu, 15 Oct 2015 13:13:40 +0200
Message-ID: <32616276616701280f2d6da44f0cbaf7fb93f5bf.1444907416.git.tgraf@suug.ch>
References: <cover.1444907416.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	jbenc@redhat.com, mengke.liu@intel.com, tom@herbertland.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45956 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223AbbJOLNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 07:13:51 -0400
In-Reply-To: <cover.1444907416.git.tgraf@suug.ch>
In-Reply-To: <cover.1444907416.git.tgraf@suug.ch>
References: <cover.1444907416.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch updates ip-route man page with lwtunnel encap
usage and description, covering MPLS and IP encapsulation.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 man/man8/ip-route.8.in | 70 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 69 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 72d8d77..9934a1e 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -80,6 +80,8 @@ replace " } "
 
 .ti -8
 .IR NH " := [ "
+.B  encap
+.IR ENCAP " ] [ "
 .B  via
 [
 .IR FAMILY " ] " ADDRESS " ] [ "
@@ -164,6 +166,26 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .IR PREF " := [ "
 .BR low " | " medium " | " high " ]"
 
+.ti -8
+.IR ENCAP " := [ "
+.IR MPLS " | " IP " ]"
+
+.ti -8
+.IR ENCAP_MPLS " := "
+.BR mpls " [ "
+.IR LABEL " ]"
+
+.ti -8
+.IR ENCAP_IP " := "
+.B ip
+.B id
+.IR TUNNEL_ID
+.B  dst
+.IR REMOTE_IP " [ "
+.B tos
+.IR TOS " ] ["
+.B  ttl
+.IR TTL " ]"
 
 .SH DESCRIPTION
 .B ip route
@@ -589,6 +611,48 @@ Discovery messages. Namely:
 - the route has a highest priority
 .sp
 
+.TP
+.BI encap " ENCAPTYPE ENCAPHDR"
+attach tunnel encapsulation attributes to this route.
+.sp
+.I ENCAPTYPE
+is a string specifying the supported encapsulation type. Namely:
+
+.in +8
+.BI mpls
+- encapsulation type MPLS
+.sp
+.BI ip
+- IP encapsulation (Geneve, GRE, VXLAN, ...)
+.sp
+
+.in -8
+.I ENCAPHDR
+is a set of encapsulation attributes specific to the
+.I ENCAPTYPE.
+
+.in +8
+.B mpls
+.in +2
+.I MPLSLABEL
+- mpls label stack with labels separated by
+.I "/"
+.in -2
+.sp
+
+.B ip
+.in +2
+.B id
+.I TUNNEL_ID
+.B  dst
+.IR REMOTE_IP " [ "
+.B tos
+.IR TOS " ] ["
+.B  ttl
+.IR TTL " ]"
+.in -2
+.sp
+
 .in -8
 .RE
 
@@ -847,7 +911,11 @@ ip route add default via 192.168.1.1 dev eth0
 Adds a default route (for all addresses) via the local gateway 192.168.1.1 that can
 be reached on device eth0.
 .RE
-
+.PP
+ip route add 10.1.1.0/30 encap mpls 200/300 via 10.1.1.1 dev eth0
+.RS 4
+Adds an ipv4 route with mpls encapsulation attributes attached to it.
+.RE
 .SH SEE ALSO
 .br
 .BR ip (8)
-- 
2.4.3
