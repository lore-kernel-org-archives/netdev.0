From: Horms <horms@verge.net.au>
Subject: [patch 3/4] Make sure ip_vs_ftp ports are valid
Date: Fri, 01 Sep 2006 19:10:39 +0900
Message-ID: <20060901101756.637601000@tabatha.lab.ultramonkey.org>
References: <20060901101036.181146000@tabatha.lab.ultramonkey.org>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Joseph Mack NA3T <jmack@wm7d.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:47792 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S1751408AbWIAKgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 06:36:18 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=ip_vs_ftp-ignore-invalid.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm not entirely sure what happens in the case of a valid port,
at best it'll be silently ignored. This patch ignores them a little
more verbosely.

Signed-Off-By: Simon Horman <horms@verge.net.au>
Index: linux-2.6/net/ipv4/ipvs/ip_vs_ftp.c
===================================================================
--- linux-2.6.orig/net/ipv4/ipvs/ip_vs_ftp.c	2006-09-01 19:06:42.000000000 +0900
+++ linux-2.6/net/ipv4/ipvs/ip_vs_ftp.c	2006-09-01 19:08:19.000000000 +0900
@@ -373,6 +373,12 @@
 	for (i=0; i<IP_VS_APP_MAX_PORTS; i++) {
 		if (!ports[i])
 			continue;
+		if (ports[i] < 0 || ports[i] > 0xffff) {
+			IP_VS_WARNING("ip_vs_ftp: Ignoring invalid "
+				      "configuration port[%d] = %d\n",
+				      i, ports[i]);
+			continue;
+		}
 		ret = register_ip_vs_app_inc(app, app->protocol, ports[i]);
 		if (ret)
 			break;

--

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

