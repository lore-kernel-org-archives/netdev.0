From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 10/16] ipvs: clean the init_ipv4_mibs error paths
Date: Thu, 17 Jul 2008 17:33:16 +0400
Message-ID: <487F4A1C.5040900@openvz.org>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:51006 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754792AbYGQNdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:33:21 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After moving all the stuff outside this function it looks
a bit ugly - make it look better.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/ipv4/af_inet.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 36ff6dc..dd919d8 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1399,13 +1399,7 @@ static __net_initdata struct pernet_operations ipv4_mib_ops = {
 
 static int __init init_ipv4_mibs(void)
 {
-	if (register_pernet_subsys(&ipv4_mib_ops))
-		goto err_net;
-
-	return 0;
-
-err_net:
-	return -ENOMEM;
+	return register_pernet_subsys(&ipv4_mib_ops);
 }
 
 static int ipv4_proc_init(void);
-- 
1.5.5.1

