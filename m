From: Andrew McDonald <andrew@mcdonald.org.uk>
Subject: [patch] ipv6.7: IPV6_ROUTER_ALERT sockopt correction
Date: Sun, 14 Oct 2007 12:11:47 +0100
Message-ID: <20071014111147.GE20850@mcdonald.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-man@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from widget.mcdonald.org.uk ([81.187.72.227]:1199 "EHLO
	widget.mcdonald.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755498AbXJNL7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 07:59:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I discovered that the current description of the IPV6_ROUTER_ALERT
sockopt in ipv6.7 is significantly wrong. A patch to fix the
description is below. I sent a version of this earlier in the year to
mtk-manpages@gmx.net, but nothing happened with it at the time.

The correction is based on reading the relevant parts of the kernel
source code, and backed up by some test programs. The main bits of code
in the kernel (in case someone wants to double-check my update) are
net/ipv6/ipv6_sockglue.c:ip6_ra_control() and
net/ipv6/ip6_output.c:ip6_call_ra_chain().

The patch is against man-pages-2.66.

regards,

Andrew


--- man7/ipv6.7.orig	2007-10-14 11:59:46.000000000 +0100
+++ man7/ipv6.7	2007-10-14 12:05:15.000000000 +0100
@@ -233,10 +233,17 @@
 Argument is a pointer to boolean.
 .TP
 .B IPV6_ROUTER_ALERT
-Pass all forwarded packets containing an router alert option to
+Pass forwarded packets containing a router alert hop-by-hop option to
 this socket.
-Only allowed for datagram sockets and for root.
-Argument is a pointer to boolean.
+Only allowed for SOCK_RAW sockets.
+The tapped packets are not forwarded by the kernel, it is the
+user's responsibility to send them out again.
+Argument is a pointer to an integer.
+A positive integer indicates a router alert option value to intercept.
+Packets carrying a router alert option with a value field containing
+this integer will be delivered to the socket.
+A negative integer disables delivery of packets with router alert options
+to this socket.
 .TP
 .B IPV6_UNICAST_HOPS
 Set the unicast hop limit for the socket.
