From: Michal Ludvig <michal@logix.cz>
Subject: [PATCH] ip_gre.c in 2.6.0-test5
Date: Wed, 24 Sep 2003 10:34:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F715732.5060306@logix.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040205010907060203000308"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040205010907060203000308
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi all,
this trivial patch fixes possible kernel crash when using GRE tunnels in 
2.6.0-test. The problem was that "dev->init" wasn't set before 
register_netdevice() call and so the initialization function was never 
called. Consequently some fields in the tunnel structure were not 
initialized what finally led to a kernel crash upon receiving the first 
packet over the GRE tunnel.

Michal Ludvig
-- 
* A mouse is a device used to point at the xterm you want to type in.
* Personal homepage - http://www.logix.cz/~mic

--------------040205010907060203000308
Content-Type: text/plain;
 name="kernel-ip_gre-1.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kernel-ip_gre-1.diff"

# Patch for http://bugme.osdl.org/show_bug.cgi?id=1130 
# Applies cleanly to 2.6.0-test5
# Michal Ludvig <mludvig@suse.cz>
--- linux-2.6.0-test5-clean/net/ipv4/ip_gre.c	2003-09-08 21:50:18.000000000 +0200
+++ linux-2.6.0-test5/net/ipv4/ip_gre.c	2003-09-23 16:50:09.000000000 +0200
@@ -271,13 +271,17 @@ static struct ip_tunnel * ipgre_tunnel_l
 	}
 
 	dev = alloc_netdev(sizeof(*t), name, ipgre_tunnel_setup);
+	if (!dev)
+	  return NULL;
+
+	dev->init = ipgre_tunnel_init;
+
 	if (register_netdevice(dev) < 0) {
 		kfree(dev);
 		goto failed;
 	}
 
 	nt = dev->priv;
-	dev->init = ipgre_tunnel_init;
 	nt->parms = *parms;
 
 	dev_hold(dev);

--------------040205010907060203000308--
