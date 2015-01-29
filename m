From: Tom Herbert <therbert@google.com>
Subject: [PATCH iproute2 4/4] iproute: Descriptions of fou and gue options in ip-link man pages
Date: Thu, 29 Jan 2015 08:52:01 -0800
Message-ID: <1422550321-30901-5-git-send-email-therbert@google.com>
References: <1422550321-30901-1-git-send-email-therbert@google.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:51209 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755143AbbA2Qxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 11:53:34 -0500
Received: by mail-ie0-f174.google.com with SMTP id vy18so36062274iec.5
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 08:53:34 -0800 (PST)
In-Reply-To: <1422550321-30901-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add section for additional arguments to GRE, IPIP, and SIT types
that are related to Foo-over-UDP and Generic UDP Encapsulation.
Also, added an example GUE configuration in the examples section.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 man/man8/ip-link.8.in | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 67 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index a0be895..2634590 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -369,6 +369,63 @@ are entered into the VXLAN device forwarding database.
 .in -8
 
 .TP
+GRE, IPIP, SIT Type Support
+For a link of types
+.I GRE/IPIP/SIT
+the following additional arguments are supported:
+
+.BI "ip link add " DEVICE
+.BR type " { gre | ipip | sit } "
+.BI " remote " ADDR " local " ADDR
+.R " [ "
+.BR encap " { fou | gue | none } "
+.R " ] [ "
+.BI "encap-sport { " PORT " | auto } "
+.R " ] [ "
+.BI "encap-dport " PORT
+.R " ] [ "
+.I " [no]encap-csum "
+.R " ] [ "
+.I " [no]encap-remcsum "
+.R " ]"
+
+.in +8
+.sp
+.BI  remote " ADDR "
+- specifies the remote address of the tunnel.
+
+.sp
+.BI  local " ADDR "
+- specifies the fixed local address for tunneled packets.
+It must be an address on another interface on this host.
+
+.sp
+.BR encap " { fou | gue | none } "
+- specifies type of secondary UDP encapsulation. "fou" indicates
+Foo-Over-UDP, "gue" indicates Generic UDP Encapsulation.
+
+.sp
+.BI "encap-sport { " PORT " | auto } "
+- specifies the source port in UDP encapsulation.
+.IR PORT
+indicates the port by number, "auto"
+indicates that the port number should be chosen automatically
+(the kernel picks a flow based on the flow hash of the
+encapsulated packet).
+
+.sp
+.I [no]encap-csum
+- specifies if UDP checksums are enabled in the secondary
+encapsulation.
+
+.sp
+.I [no]encap-remcsum
+- specifies if Remote Checksum Offload is enabled. This is only
+applicable for Generic UDP Encapsulation.
+
+.in -8
+
+.TP
 IP6GRE/IP6GRETAP Type Support
 For a link of type
 .I IP6GRE/IP6GRETAP
@@ -404,7 +461,7 @@ the following additional arguments are supported:
 .sp
 .BI  local " ADDR "
 - specifies the fixed local IPv6 address for tunneled packets.
-It must be and address on another interface on this host.
+It must be an address on another interface on this host.
 
 .sp
 .BI  [i|o]seq
@@ -781,6 +838,15 @@ ip link help gre
 .RS 4
 Display help for the gre link type.
 .RE
+.PP
+ip link add name tun1 type ipip remote 192.168.1.1
+local 192.168.1.2 ttl 225 encap gue encap-sport auto
+encap-dport 5555 encap-csum encap-remcsum
+.RS 4
+Creates an IPIP that is encapsulated with Generic UDP Encapsulation,
+and the outer UDP checksum and remote checksum offload are enabled.
+
+.RE
 
 .SH SEE ALSO
 .br
-- 
2.2.0.rc0.207.ga3a616c
