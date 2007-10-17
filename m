From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Cleanup snmp6_alloc_dev()
Date: Wed, 17 Oct 2007 14:44:44 +0400
Message-ID: <4715E79C.80306@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:54581 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753176AbXJQKrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 06:47:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This functions is never called with NULL or not setup argument,
so the checks inside are redundant.

Also, the return value is always -ENOMEM, so no need in 
additional variable for this.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 52d10d2..c173549 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -255,11 +255,6 @@ static void addrconf_mod_timer(struct inet6_ifaddr *ifp,
 
 static int snmp6_alloc_dev(struct inet6_dev *idev)
 {
-	int err = -ENOMEM;
-
-	if (!idev || !idev->dev)
-		return -EINVAL;
-
 	if (snmp_mib_init((void **)idev->stats.ipv6,
 			  sizeof(struct ipstats_mib),
 			  __alignof__(struct ipstats_mib)) < 0)
@@ -280,7 +275,7 @@ err_icmpmsg:
 err_icmp:
 	snmp_mib_free((void **)idev->stats.ipv6);
 err_ip:
-	return err;
+	return -ENOMEM;
 }
 
 static int snmp6_free_dev(struct inet6_dev *idev)
