From: Randolph Chung <randolph@tausq.org>
Subject: [patch] gcc-4.0 fix for acenic
Date: Wed, 10 Nov 2004 11:44:01 -0800
Message-ID: <20041110194401.GL15714@tausq.org>
Reply-To: Randolph Chung <randolph@tausq.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: torvalds@osdl.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Small fix to compile acenic with gcc-4.0. gcc no longer accepts static
function prototypes inside a function definition. This is ugly anyway...

Signed-off-by: Randolph Chung <tausq@debian.org>
Acked-by: Jes Sorensen

Index: drivers/net/acenic.c
===================================================================
RCS file: /var/cvs/linux-2.6/drivers/net/acenic.c,v
retrieving revision 1.12
diff -u -p -r1.12 acenic.c
--- linux/drivers/net/acenic.c	21 Oct 2004 18:59:05 -0000	1.12
+++ linux/drivers/net/acenic.c	10 Nov 2004 19:33:43 -0000
@@ -450,6 +450,7 @@ static char version[] __initdata = 
 static int ace_get_settings(struct net_device *, struct ethtool_cmd *);
 static int ace_set_settings(struct net_device *, struct ethtool_cmd *);
 static void ace_get_drvinfo(struct net_device *, struct ethtool_drvinfo *);
+static void ace_watchdog(struct net_device *dev);
 
 static struct ethtool_ops ace_ethtool_ops = {
 	.get_settings = ace_get_settings,
@@ -485,7 +486,6 @@ static int __devinit acenic_probe_one(st
 	dev->vlan_rx_kill_vid = ace_vlan_rx_kill_vid;
 #endif
 	if (1) {
-		static void ace_watchdog(struct net_device *dev);
 		dev->tx_timeout = &ace_watchdog;
 		dev->watchdog_timeo = 5*HZ;
 	}
-- 
Randolph Chung
Debian GNU/Linux Developer, hppa/ia64 ports
http://www.tausq.org/
