From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bpqether add rcu_read_lock
Date: Tue, 12 Aug 2003 15:33:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812153312.0e762cf3.shemminger@osdl.org>
References: <20030811162205.78b2029f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Joerg Reuter <jreuter@yaina.de>,
   linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030811162205.78b2029f.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix one comment and add rcu_read_lock/rcu_read_unlock in the net_device_notifier.
Preemption is almost certainly already disabled there, but be safe.

diff -Nru a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
--- a/drivers/net/hamradio/bpqether.c	Tue Aug 12 11:37:28 2003
+++ b/drivers/net/hamradio/bpqether.c	Tue Aug 12 11:37:28 2003
@@ -141,7 +141,6 @@
 
 /*
  *	Get the BPQ device for the ethernet device
- * need to hold bqp_lock at least for read
  */
 static inline struct net_device *bpq_get_ax25_dev(struct net_device *dev)
 {
@@ -564,6 +563,8 @@
 	if (!dev_is_ethdev(dev))
 		return NOTIFY_DONE;
 
+	rcu_read_lock();
+
 	switch (event) {
 	case NETDEV_UP:		/* new ethernet device -> new BPQ interface */
 		if (bpq_get_ax25_dev(dev) == NULL)
@@ -582,6 +583,7 @@
 	default:
 		break;
 	}
+	rcu_read_unlock();
 
 	return NOTIFY_DONE;
 }
