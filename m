From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next 1/2] tc: flower: document that *_ip parameters take a PREFIX as an argument.
Date: Fri, 16 Dec 2016 14:54:36 +0100
Message-ID: <1481896477-13497-2-git-send-email-simon.horman@netronome.com>
References: <1481896477-13497-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38344 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934934AbcLPODW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 09:03:22 -0500
Received: by mail-wm0-f53.google.com with SMTP id f82so36226156wmf.1
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 06:03:21 -0800 (PST)
In-Reply-To: <1481896477-13497-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* The argument to src_ip, dst_ip, enc_src_ip and enc_dst_ip take an
  optional prefix length which is used to provide a mask to limit the scope
  of matching.
* This is documented as a PREFIX in keeping with ip-route(8).

Example of uses of IPv4 and IPv6 prefixes

tc qdisc add dev eth0 ingress
tc filter add dev eth0 protocol ip parent ffff: flower \
    indev eth0 dst_ip 192.168.1.1 action drop
tc filter add dev eth0 protocol ip parent ffff: flower \
    indev eth0 src_ip 10.0.0.0/8 action drop
tc filter add dev eth0 protocol ipv6 parent ffff: flower \
    indev eth0 src_ip 2001:DB8:1::/48 action drop
tc filter add dev eth0 protocol ipv6 parent ffff: flower \
    indev eth0 dst_ip 2001:DB8::1 action drop

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 man/man8/tc-flower.8 | 28 ++++++++++++++--------------
 tc/f_flower.c        |  8 ++++----
 2 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index 88df83360b89..a383b6584dc6 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -31,8 +31,8 @@ flower \- flow based traffic control filter
 .IR ETH_TYPE " } | "
 .BR ip_proto " { " tcp " | " udp " | " sctp " | " icmp " | " icmpv6 " | "
 .IR IP_PROTO " } | { "
-.BR dst_ip " | " src_ip " } { "
-.IR ipv4_address " | " ipv6_address " } | { "
+.BR dst_ip " | " src_ip " } "
+.IR PREFIX " | { "
 .BR dst_port " | " src_port " } "
 .IR port_number " } | "
 .B enc_key_id
@@ -103,14 +103,14 @@ may be
 .BR tcp ", " udp ", " sctp ", " icmp ", " icmpv6
 or an unsigned 8bit value in hexadecimal format.
 .TP
-.BI dst_ip " ADDRESS"
+.BI dst_ip " PREFIX"
 .TQ
-.BI src_ip " ADDRESS"
+.BI src_ip " PREFIX"
 Match on source or destination IP address.
-.I ADDRESS
-must be a valid IPv4 or IPv6 address, depending on
-.BR protocol
-option of tc filter.
+.I PREFIX
+must be a valid IPv4 or IPv6 address, depending on the \fBprotocol\fR
+option to tc filter, optionally followed by a slash and the prefix length.
+If the prefix is missing, \fBtc\fR assumes a full-length host match.
 .TP
 .BI dst_port " NUMBER"
 .TQ
@@ -128,16 +128,16 @@ which have to be specified in beforehand.
 .TP
 .BI enc_key_id " NUMBER"
 .TQ
-.BI enc_dst_ip " ADDRESS"
+.BI enc_dst_ip " PREFIX"
 .TQ
-.BI enc_src_ip " ADDRESS"
-.TQ
-.BI enc_dst_port " NUMBER"
+.BI enc_src_ip " PREFIX"
 Match on IP tunnel metadata. Key id
 .I NUMBER
 is a 32 bit tunnel key id (e.g. VNI for VXLAN tunnel).
-.I ADDRESS
-must be a valid IPv4 or IPv6 address. Dst port
+.I PREFIX
+must be a valid IPv4 or IPv6 address optionally followed by a slash and the
+prefix length. If the prefix is missing, \fBtc\fR assumes a full-length
+host match.  Dst port
 .I NUMBER
 is a 16 bit UDP dst port.
 .SH NOTES
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 653dfefc060a..cdf74344f78f 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -48,14 +48,14 @@ static void explain(void)
 		"                       dst_mac MAC-ADDR |\n"
 		"                       src_mac MAC-ADDR |\n"
 		"                       ip_proto [tcp | udp | sctp | icmp | icmpv6 | IP-PROTO ] |\n"
-		"                       dst_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
-		"                       src_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
+		"                       dst_ip PREFIX |\n"
+		"                       src_ip PREFIX |\n"
 		"                       dst_port PORT-NUMBER |\n"
 		"                       src_port PORT-NUMBER |\n"
 		"                       type ICMP-TYPE |\n"
 		"                       code ICMP-CODE }\n"
-		"                       enc_dst_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
-		"                       enc_src_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
+		"                       enc_dst_ip PREFIX |\n"
+		"                       enc_src_ip PREFIX |\n"
 		"                       enc_key_id [ KEY-ID ] }\n"
 		"       FILTERID := X:Y:Z\n"
 		"       ACTION-SPEC := ... look at individual actions\n"
-- 
2.7.0.rc3.207.g0ac5344
