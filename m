From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] af_mpls: fix undefined reference to ip6_route_output
Date: Wed, 22 Jul 2015 00:10:03 -0700
Message-ID: <1437549003-35563-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34012 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138AbbGVHKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 03:10:08 -0400
Received: by pacan13 with SMTP id an13so135170024pac.1
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 00:10:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

seen with CONFIG_IPV6 disabled. Wrap the code
around IS_ENABLED(CONFIG_IPV6)

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 49f1b0e..040dfff 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -351,6 +351,7 @@ errout:
 	return dev;
 }
 
+#if IS_ENABLED(CONFIG_IPV6)
 static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
 {
 	struct net_device *dev = NULL;
@@ -371,6 +372,12 @@ errout:
 
 	return dev;
 }
+#else
+static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
+{
+	return NULL;
+}
+#endif
 
 static struct net_device *find_outdev(struct net *net,
 				      struct mpls_route_config *cfg)
-- 
1.7.10.4
