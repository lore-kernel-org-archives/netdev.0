From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (8/11) netrom - make lists and locks static
Date: Wed, 13 Aug 2003 15:45:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813154517.6c82f112.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeroen Vreeken <pe1rxq@amsat.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Make lists and locks static since they are only used in one file.


diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	Wed Aug 13 13:31:48 2003
+++ b/net/netrom/af_netrom.c	Wed Aug 13 13:31:48 2003
@@ -57,8 +57,8 @@
 
 static unsigned short circuit = 0x101;
 
-HLIST_HEAD(nr_list);
-static spinlock_t nr_list_lock;
+static HLIST_HEAD(nr_list);
+static spinlock_t nr_list_lock = SPIN_LOCK_UNLOCKED;
 
 static struct proto_ops nr_proto_ops;
 
diff -Nru a/net/netrom/nr_route.c b/net/netrom/nr_route.c
--- a/net/netrom/nr_route.c	Wed Aug 13 13:31:48 2003
+++ b/net/netrom/nr_route.c	Wed Aug 13 13:31:48 2003
@@ -39,10 +39,10 @@
 
 static unsigned int nr_neigh_no = 1;
 
-HLIST_HEAD(nr_node_list);
-spinlock_t nr_node_list_lock = SPIN_LOCK_UNLOCKED;
-HLIST_HEAD(nr_neigh_list);
-spinlock_t nr_neigh_list_lock = SPIN_LOCK_UNLOCKED;
+static HLIST_HEAD(nr_node_list);
+static spinlock_t nr_node_list_lock = SPIN_LOCK_UNLOCKED;
+static HLIST_HEAD(nr_neigh_list);
+static spinlock_t nr_neigh_list_lock = SPIN_LOCK_UNLOCKED;
 
 struct nr_node *nr_node_get(ax25_address *callsign)
 {
