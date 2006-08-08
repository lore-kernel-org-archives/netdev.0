From: louis.nyffenegger@gmail.com
Subject: remove is_setbyuser patch
Date: Tue, 8 Aug 2006 10:02:31 +0200
Message-ID: <20060808080231.GB13512@prozac>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:34175 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932107AbWHHHxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 03:53:45 -0400
Received: by nf-out-0910.google.com with SMTP id q29so78795nfc
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2006 00:53:44 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The same without gmail problems

== Changelog ==

The value is_setbyuser from struct ip_options is never used and set
only one time (http://linux-net.osdl.org/index.php/TODO#IPV4).
This little patch removes it from the kernel source.

Signed-off-by: Louis Nyffenegger <louis.nyffenegger@gmail.com>

== Patch ==


--- /usr/src/linux/include/net/inet_sock.h.orig	2006-08-07 17:44:18.000000000 +0200
+++ /usr/src/linux/include/net/inet_sock.h	2006-08-07 17:44:49.000000000 +0200
@@ -28,7 +28,6 @@
 /** struct ip_options - IP Options
  *
  * @faddr - Saved first hop address
- * @is_setbyuser - Set by setsockopt?
  * @is_data - Options in __data, rather than skb
  * @is_strictroute - Strict source route
  * @srr_is_hit - Packet destination addr was our one
@@ -43,8 +42,7 @@ struct ip_options {
 	unsigned char	srr;
 	unsigned char	rr;
 	unsigned char	ts;
-	unsigned char	is_setbyuser:1,
-			is_data:1,
+	unsigned char	is_data:1,
 			is_strictroute:1,
 			srr_is_hit:1,
 			is_changed:1,



--- /usr/src/linux/net/ipv4/ip_options.c.orig	2006-08-07 17:45:12.000000000 +0200
+++ /usr/src/linux/net/ipv4/ip_options.c	2006-08-07 17:45:23.000000000 +0200
@@ -507,7 +507,6 @@ static int ip_options_get_finish(struct 
 		opt->__data[optlen++] = IPOPT_END;
 	opt->optlen = optlen;
 	opt->is_data = 1;
-	opt->is_setbyuser = 1;
 	if (optlen && ip_options_compile(opt, NULL)) {
 		kfree(opt);
 		return -EINVAL;
