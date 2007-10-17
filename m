From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Fix memory leak in cleanup_ipv6_mibs()
Date: Wed, 17 Oct 2007 18:04:18 +0400
Message-ID: <47161662.2080706@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41984 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759316AbXJQOE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 10:04:26 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The icmpv6msg mib statistics is not freed.

This is almost not critical for current kernel, since ipv6
module is unloadable, but this can happen on load error and 
will happen every time we stop the network namespace (when 
we have one, of course).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index bc92938..1b1caf3 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -747,6 +747,7 @@ static void cleanup_ipv6_mibs(void)
 {
 	snmp_mib_free((void **)ipv6_statistics);
 	snmp_mib_free((void **)icmpv6_statistics);
+	snmp_mib_free((void **)icmpv6msg_statistics);
 	snmp_mib_free((void **)udp_stats_in6);
 	snmp_mib_free((void **)udplite_stats_in6);
 }
