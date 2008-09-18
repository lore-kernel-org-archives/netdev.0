From: "Nadav Shemer" <nadav.shemer@gmail.com>
Subject: iputils: ping.c - using -I for both interface and address
Date: Thu, 18 Sep 2008 20:00:39 +0300
Message-ID: <a60ec8830809181000s928a4drbd0b166be23abcee@mail.gmail.com>
Reply-To: nadav@camelot.myftp.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:49809 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833AbYIRRAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 13:00:41 -0400
Received: by gxk9 with SMTP id 9so31509012gxk.13
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2008 10:00:40 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I use 'ping 1.2.3.4 -I eth1 -I 2.3.4.5' the packets come out with
eth1's address anyway.
It seems to me that IP_PKTINFO is set for every packet, with
ipi_spec_dst set to 0. This overrides the inet->saddr set by bind.

Here's a fix:
--- ping.c	2007-11-27 02:57:27.000000000 +0200
+++ ping.c.patched	2008-09-18 19:59:45.000000000 +0300
@@ -350,6 +350,8 @@
 			fprintf(stderr, "ping: unknown iface %s\n", device);
 			exit(2);
 		}
+		if (options & F_STRICTSOURCE)
+			cmsg.ipi.ipi_spec_dst.s_addr = source.sin_addr.s_addr;
 		cmsg.ipi.ipi_ifindex = ifr.ifr_ifindex;
 		cmsg_len = sizeof(cmsg);
 	}
