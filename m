From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/5] tcp: set default congestion control when no sysctl
Date: Tue, 31 Oct 2006 15:01:41 -0800
Message-ID: <20061031230213.529807216@osdl.org>
References: <20061031230140.191929094@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:24762 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423858AbWJaXEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 18:04:12 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=tcp-default-no-sysctl.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The setting of the default congestion control was buried in
the sysctl code so it would not be done properly if SYSCTL was
not enabled.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


---
 net/ipv4/sysctl_net_ipv4.c |    7 -------
 net/ipv4/tcp_cong.c        |    8 ++++++++
 2 files changed, 8 insertions(+), 7 deletions(-)

--- tcp.orig/net/ipv4/sysctl_net_ipv4.c	2006-10-31 12:22:43.000000000 -0800
+++ tcp/net/ipv4/sysctl_net_ipv4.c	2006-10-31 12:22:56.000000000 -0800
@@ -129,13 +129,6 @@
 	return ret;
 }
 
-static int __init tcp_congestion_default(void)
-{
-	return tcp_set_default_congestion_control(CONFIG_DEFAULT_TCP_CONG);
-}
-
-late_initcall(tcp_congestion_default);
-
 ctl_table ipv4_table[] = {
         {
 		.ctl_name	= NET_IPV4_TCP_TIMESTAMPS,
--- tcp.orig/net/ipv4/tcp_cong.c	2006-10-31 12:22:33.000000000 -0800
+++ tcp/net/ipv4/tcp_cong.c	2006-10-31 12:23:42.000000000 -0800
@@ -131,6 +131,14 @@
 	return ret;
 }
 
+/* Set default value from kernel configuration at bootup */
+static int __init tcp_congestion_default(void)
+{
+	return tcp_set_default_congestion_control(CONFIG_DEFAULT_TCP_CONG);
+}
+late_initcall(tcp_congestion_default);
+
+
 /* Get current default congestion control */
 void tcp_get_default_congestion_control(char *name)
 {

--
Stephen Hemminger <shemminger@osdl.org>

