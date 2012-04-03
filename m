From: fernando@intellilink.co.jp
Subject: [PATCH 2/2] TCP: Use 32768-65535 outgoing port range by default
Date: Tue,  3 Apr 2012 09:50:18 +0900
Message-ID: <20120403095018.rm7gil9xz0gsgccs@webmail.int.intellilink.co.jp>
References: <20120403094840.ftxlwztl40gwcg4s@webmail.int.intellilink.co.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="=_nmq9e3psui"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ils-mail01.intellilink.co.jp ([61.115.36.70]:50403 "EHLO
	ils-mail01.intellilink.co.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751691Ab2DCBLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 21:11:03 -0400
In-Reply-To: <20120403094840.ftxlwztl40gwcg4s@webmail.int.intellilink.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message is in MIME format.

--=_nmq9e3psui
Content-Type: text/plain;
	charset=ISO-2022-JP;
	format="flowed"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit



--=_nmq9e3psui
Content-Type: text/plain;
	charset=ISO-2022-JP;
	name="sysctl-ip_local_port_range-change-default.patch"
Content-Disposition: attachment;
	filename="sysctl-ip_local_port_range-change-default.patch"
Content-Transfer-Encoding: 7bit

Subject: [PATCH] TCP: Use 32768-65535 outgoing port range by default

From: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>

There was a time when the ip masquerading code reserved the 61000-65095
port range, which is the reason why the current default upper limit in
ip_local_port_range is 61000. However, the current iptables-based
masquerading and SNAT implementation does not have that restriction;
ipchains and the compatibilty mode that used the range over 61000
exclusively is lone gone.

Bump up the last local port number used by default to the maximum, i.e.
65535, so that we can have more connections in the system without
eating deeper into IANA assigned range.

Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
---

diff -urNp linux-3.4-rc1-orig/Documentation/networking/ip-sysctl.txt linux-3.4-rc1/Documentation/networking/ip-sysctl.txt
--- linux-3.4-rc1-orig/Documentation/networking/ip-sysctl.txt	2012-04-03 08:51:37.325983165 +0900
+++ linux-3.4-rc1/Documentation/networking/ip-sysctl.txt	2012-04-03 08:53:52.282652377 +0900
@@ -605,7 +605,7 @@ ip_local_port_range - 2 INTEGERS
 	Defines the local port range that is used by TCP and UDP to
 	choose the local port. The first number is the first, the
 	second the last local port number. The default values are 
-	32768 and 61000 respectively.
+	32768 and 65535 respectively.
 
 	These two numbers determine the number of active connections
 	which this system can issue simultaneously to systems not
diff -urNp linux-3.4-rc1-orig/net/ipv4/inet_connection_sock.c linux-3.4-rc1/net/ipv4/inet_connection_sock.c
--- linux-3.4-rc1-orig/net/ipv4/inet_connection_sock.c	2012-03-19 08:15:34.000000000 +0900
+++ linux-3.4-rc1/net/ipv4/inet_connection_sock.c	2012-04-03 08:52:15.350171717 +0900
@@ -34,7 +34,7 @@ EXPORT_SYMBOL(inet_csk_timer_bug_msg);
  */
 struct local_ports sysctl_local_ports __read_mostly = {
 	.lock = __SEQLOCK_UNLOCKED(sysctl_local_ports.lock),
-	.range = { 32768, 61000 },
+	.range = { 32768, 65535 },
 };
 
 unsigned long *sysctl_local_reserved_ports;

--=_nmq9e3psui--
