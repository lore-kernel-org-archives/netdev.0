From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/5] ipvs: Expose ip_vs_ftp module parameters via sysfs.
Date: Mon, 26 Sep 2011 18:05:34 +0900
Message-ID: <1317027938-22053-2-git-send-email-horms@verge.net.au>
References: <1317027938-22053-1-git-send-email-horms@verge.net.au>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>,
	Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>,
	Simon Horman <horms@verge.net.au>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:51149 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285Ab1IZJGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 05:06:00 -0400
In-Reply-To: <1317027938-22053-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>

This is to expose "ports" parameter via sysfs so it can be read
at any time in order to determine what port or ports were passed
to the module at the point when it was loaded.

Signed-off-by: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
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
1.7.5.4
