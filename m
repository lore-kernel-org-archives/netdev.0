From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] convert ipvs to module_param
Date: Fri, 23 Jul 2004 13:11:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040723131142.13081ed3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, wensong@linux-vs.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert IPVS to not use MODULE_PARM.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/net/ipv4/ipvs/ip_vs_ftp.c b/net/ipv4/ipvs/ip_vs_ftp.c
--- a/net/ipv4/ipvs/ip_vs_ftp.c	2004-07-23 13:04:54 -07:00
+++ b/net/ipv4/ipvs/ip_vs_ftp.c	2004-07-23 13:04:54 -07:00
@@ -25,6 +25,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <linux/in.h>
@@ -44,16 +45,17 @@
  * First port is set to the default port.
  */
 static int ports[IP_VS_APP_MAX_PORTS] = {21, 0};
+static int ports_c;
+module_param_array(ports, int, ports_c, 0);
 
 /*
  *	Debug level
  */
 #ifdef CONFIG_IP_VS_DEBUG
 static int debug=0;
-MODULE_PARM(debug, "i");
+module_param(debug, int, 0);
 #endif
 
-MODULE_PARM(ports, "1-" __MODULE_STRING(IP_VS_APP_MAX_PORTS) "i");
 
 /*	Dummy variable */
 static int ip_vs_ftp_pasv;
