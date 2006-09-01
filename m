From: Horms <horms@verge.net.au>
Subject: [patch 4/4] remove the debug option go ip_vs_ftp
Date: Fri, 01 Sep 2006 19:10:40 +0900
Message-ID: <20060901101756.734214000@tabatha.lab.ultramonkey.org>
References: <20060901101036.181146000@tabatha.lab.ultramonkey.org>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Joseph Mack NA3T <jmack@wm7d.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:49072 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S1751393AbWIAKgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 06:36:18 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=ip_vs_ftp-debug-parameter.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the debuging behaviour of this code more consistent
with the rest of IPVS.

Signed-Off-By: Simon Horman <horms@verge.net.au>

Index: linux-2.6/net/ipv4/ipvs/ip_vs_ftp.c
===================================================================
--- linux-2.6.orig/net/ipv4/ipvs/ip_vs_ftp.c	2006-09-01 19:06:49.000000000 +0900
+++ linux-2.6/net/ipv4/ipvs/ip_vs_ftp.c	2006-09-01 19:06:50.000000000 +0900
@@ -48,14 +48,6 @@
 module_param_array(ports, int, NULL, 0);
 MODULE_PARM_DESC(ports, "Ports to monitor for FTP control commands");
 
-/*
- *	Debug level
- */
-#ifdef CONFIG_IP_VS_DEBUG
-static int debug=0;
-module_param(debug, int, 0);
-#endif
-
 
 /*	Dummy variable */
 static int ip_vs_ftp_pasv;
@@ -178,7 +170,7 @@
 					   &start, &end) != 1)
 			return 1;
 
-		IP_VS_DBG(1-debug, "PASV response (%u.%u.%u.%u:%d) -> "
+		IP_VS_DBG(7, "PASV response (%u.%u.%u.%u:%d) -> "
 			  "%u.%u.%u.%u:%d detected\n",
 			  NIPQUAD(from), ntohs(port), NIPQUAD(cp->caddr), 0);
 
@@ -281,7 +273,7 @@
 	while (data <= data_limit - 6) {
 		if (strnicmp(data, "PASV\r\n", 6) == 0) {
 			/* Passive mode on */
-			IP_VS_DBG(1-debug, "got PASV at %zd of %zd\n",
+			IP_VS_DBG(7, "got PASV at %zd of %zd\n",
 				  data - data_start,
 				  data_limit - data_start);
 			cp->app_data = &ip_vs_ftp_pasv;
@@ -303,7 +295,7 @@
 				   &start, &end) != 1)
 		return 1;
 
-	IP_VS_DBG(1-debug, "PORT %u.%u.%u.%u:%d detected\n",
+	IP_VS_DBG(7, "PORT %u.%u.%u.%u:%d detected\n",
 		  NIPQUAD(to), ntohs(port));
 
 	/* Passive mode off */
@@ -312,7 +304,7 @@
 	/*
 	 * Now update or create a connection entry for it
 	 */
-	IP_VS_DBG(1-debug, "protocol %s %u.%u.%u.%u:%d %u.%u.%u.%u:%d\n",
+	IP_VS_DBG(7, "protocol %s %u.%u.%u.%u:%d %u.%u.%u.%u:%d\n",
 		  ip_vs_proto_name(iph->protocol),
 		  NIPQUAD(to), ntohs(port), NIPQUAD(cp->vaddr), 0);
 
@@ -382,8 +374,8 @@
 		ret = register_ip_vs_app_inc(app, app->protocol, ports[i]);
 		if (ret)
 			break;
-		IP_VS_DBG(1-debug, "%s: loaded support on port[%d] = %d\n",
-			  app->name, i, ports[i]);
+		IP_VS_INFO("%s: loaded support on port[%d] = %d\n",
+		 	   app->name, i, ports[i]);
 	}
 
 	if (ret)

--

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

