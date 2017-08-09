From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH iproute2 net-next v2 3/3] man: add documentation for seg6local lwt
Date: Wed, 9 Aug 2017 17:33:26 +0200
Message-ID: <20170809153326.29599-4-david.lebrun@uclouvain.be>
References: <20170809153326.29599-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:59283 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753422AbdHIPdY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 11:33:24 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp4.sgsi.ucl.ac.be (Postfix) with ESMTPS id 4E72A67DAEF
        for <netdev@vger.kernel.org>; Wed,  9 Aug 2017 17:33:13 +0200 (CEST)
In-Reply-To: <20170809153326.29599-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds documentation in the ip-route man page
about the seg6local lightweight tunnel.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 man/man8/ip-route.8.in | 62 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 61 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index fc28492..11dd9d0 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -177,7 +177,7 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 
 .ti -8
 .IR ENCAP " := [ "
-.IR MPLS " | " IP " | " BPF " | " SEG6 " ] "
+.IR MPLS " | " IP " | " BPF " | " SEG6 " | " SEG6LOCAL " ] "
 
 .ti -8
 .IR ENCAP_MPLS " := "
@@ -221,6 +221,13 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .IR KEYID " ]"
 
 .ti -8
+.IR ENCAP_SEG6LOCAL " := "
+.B seg6local
+.BR action
+.IR SEG6_ACTION " [ "
+.IR SEG6_ACTION_PARAM " ] "
+
+.ti -8
 .IR ROUTE_GET_FLAGS " := "
 .BR " [ "
 .BR fibmatch
@@ -674,6 +681,9 @@ is a string specifying the supported encapsulation type. Namely:
 .sp
 .BI seg6
 - encapsulation type IPv6 Segment Routing
+.sp
+.BI seg6local
+- local SRv6 segment processing
 
 .in -8
 .I ENCAPHDR
@@ -749,6 +759,56 @@ is a set of encapsulation attributes specific to the
 .in -2
 .sp
 
+.B seg6local
+.in +2
+.IR SEG6_ACTION " [ "
+.IR SEG6_ACTION_PARAM " ] "
+- Operation to perform on matching packets.
+The following actions are currently supported (\fB4.14+ only\fR).
+.in +2
+
+.B End
+- Regular SRv6 processing as intermediate segment endpoint.
+This action only accepts packets with a non-zero Segments Left
+value. Other matching packets are dropped.
+
+.B End.X nh6
+.I NEXTHOP
+- Regular SRv6 processing as intermediate segment endpoint.
+Additionally, forward processed packets to given next-hop.
+This action only accepts packets with a non-zero Segments Left
+value. Other matching packets are dropped.
+
+.B End.DX6 nh6
+.I NEXTHOP
+- Decapsulate inner IPv6 packet and forward it to the
+specified next-hop. If the argument is set to ::, then
+the next-hop is selected according to the local selection
+rules. This action only accepts packets with either a zero Segments
+Left value or no SRH at all, and an inner IPv6 packet. Other
+matching packets are dropped.
+
+.B End.B6 srh segs
+.IR SEGMENTS " [ "
+.B hmac
+.IR KEYID " ] "
+- Insert the specified SRH immediately after the IPv6 header,
+update the DA with the first segment of the newly inserted SRH,
+then forward the resulting packet. The original SRH is not
+modified. This action only accepts packets with a non-zero
+Segments Left value. Other matching packets are dropped.
+
+.B End.B6.Encaps srh segs
+.IR SEGMENTS " [ "
+.B hmac
+.IR KEYID " ] "
+- Regular SRv6 processing as intermediate segment endpoint.
+Additionally, encapsulate the matching packet within an outer IPv6 header
+followed by the specified SRH. The destination address of the outer IPv6
+header is set to the first segment of the new SRH. The source
+address is set as described in \fBip-sr\fR(8).
+.in -4
+
 .in -8
 
 .TP
-- 
2.10.2
