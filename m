From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/7) ipmr.c - drop/reacquire in error path.
Date: Wed, 25 Jun 2003 11:41:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625114117.541d53cd.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In the failure path, need to drop/re-acquire locking to allow sysfs and hotplug
to run.


diff -Nru a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
--- a/net/ipv4/ipmr.c	Wed Jun 25 11:15:05 2003
+++ b/net/ipv4/ipmr.c	Wed Jun 25 11:15:05 2003
@@ -158,6 +158,10 @@
 	return dev;
 
 failure:
+	/* allow the register to be completed before unregistering. */
+	rtnl_unlock();
+	rtnl_lock();
+
 	unregister_netdevice(dev);
 	return NULL;
 }
@@ -228,6 +232,10 @@
 	return dev;
 
 failure:
+	/* allow the register to be completed before unregistering. */
+	rtnl_unlock();
+	rtnl_lock();
+
 	unregister_netdevice(dev);
 	return NULL;
 }
