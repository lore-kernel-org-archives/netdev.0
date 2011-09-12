From: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
Subject: [PATCH] ipvs: Expose ip_vs_ftp module parameters via sysfs.
Date: Mon, 12 Sep 2011 10:15:15 +0100
Message-ID: <1315818915-26288-1-git-send-email-krzysztof.wilczynski@linux.com>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41894 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754541Ab1ILJP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2011 05:15:26 -0400
Received: by wyh22 with SMTP id 22so3276377wyh.19
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2011 02:15:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to expose "ports" parameter via sysfs so it can be read
at any time in order to determine what port or ports were passed
to the module at the point when it was loaded.

Signed-off-by: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
---
 net/netfilter/ipvs/ip_vs_ftp.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 4490a32..538d74e 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -52,8 +52,9 @@
  * List of ports (up to IP_VS_APP_MAX_PORTS) to be handled by helper
  * First port is set to the default port.
  */
+static unsigned int ports_count = 1;
 static unsigned short ports[IP_VS_APP_MAX_PORTS] = {21, 0};
-module_param_array(ports, ushort, NULL, 0);
+module_param_array(ports, ushort, &ports_count, 0444);
 MODULE_PARM_DESC(ports, "Ports to monitor for FTP control commands");
 
 
@@ -449,7 +450,7 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
 	if (ret)
 		goto err_exit;
 
-	for (i=0; i<IP_VS_APP_MAX_PORTS; i++) {
+	for (i = 0; i < ports_count; i++) {
 		if (!ports[i])
 			continue;
 		ret = register_ip_vs_app_inc(net, app, app->protocol, ports[i]);
-- 
1.7.0.4
