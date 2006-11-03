From: Dmitry Mishin <dim@openvz.org>
Subject: [PATCH] add ndisc_netdev_notifier unregister
Date: Fri, 3 Nov 2006 17:20:07 +0300
Message-ID: <200611031720.07813.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:11025 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S1752976AbWKCOUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 09:20:11 -0500
Received: from dhcp0-24.sw.ru ([192.168.0.24])
	by relay.sw.ru (8.13.4/8.13.4) with ESMTP id kA3EK89K022924
	for <netdev@vger.kernel.org>; Fri, 3 Nov 2006 17:20:09 +0300 (MSK)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If inet6_init() fails later than ndisc_init() call, or IPv6 module is 
unloaded, ndisc_netdev_notifier call remains in the list and will follows in 
oops later.

Signed-off-by: Dmitry Mishin <dim@openvz.org>
---
 ndisc.c |    1 +
 1 file changed, 1 insertion(+)
---
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 41a8a5f..73eb8c3 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1742,6 +1742,7 @@ #endif
 
 void ndisc_cleanup(void)
 {
+	unregister_netdevice_notifier(&ndisc_netdev_notifier);
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_unregister(&nd_tbl.parms);
 #endif
