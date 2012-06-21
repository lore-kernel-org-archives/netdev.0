From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 10/20] batman-adv: Prefix icmp-socket
	non-static functions with batadv_
Date: Thu, 21 Jun 2012 18:57:46 +0200
Message-ID: <1340297876-29923-11-git-send-email-ordex@autistici.org>
References: <1340297876-29923-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340297876-29923-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

batman-adv can be compiled as part of the kernel instead of an module. In that
case the linker will see all non-static symbols of batman-adv and all other
non-static symbols of the kernel. This could lead to symbol collisions. A
prefix for the batman-adv symbols that defines their private namespace avoids
such a problem.

Reported-by: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bat_debugfs.c |    2 +-
 net/batman-adv/icmp_socket.c |    8 ++++----
 net/batman-adv/icmp_socket.h |    8 ++++----
 net/batman-adv/main.c        |    2 +-
 net/batman-adv/routing.c     |    2 +-
 5 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index 7b294b4..9177a06 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -349,7 +349,7 @@ int batadv_debugfs_add_meshif(struct net_device *dev)
 	if (!bat_priv->debug_dir)
 		goto out;
 
-	if (bat_socket_setup(bat_priv) < 0)
+	if (batadv_socket_setup(bat_priv) < 0)
 		goto rem_attr;
 
 	if (debug_log_setup(bat_priv) < 0)
diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index d27db81..38ca3a8 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -34,7 +34,7 @@ static void bat_socket_add_packet(struct socket_client *socket_client,
 				  struct icmp_packet_rr *icmp_packet,
 				  size_t icmp_len);
 
-void bat_socket_init(void)
+void batadv_socket_init(void)
 {
 	memset(socket_client_hash, 0, sizeof(socket_client_hash));
 }
@@ -276,7 +276,7 @@ static const struct file_operations fops = {
 	.llseek = no_llseek,
 };
 
-int bat_socket_setup(struct bat_priv *bat_priv)
+int batadv_socket_setup(struct bat_priv *bat_priv)
 {
 	struct dentry *d;
 
@@ -336,8 +336,8 @@ static void bat_socket_add_packet(struct socket_client *socket_client,
 	wake_up(&socket_client->queue_wait);
 }
 
-void bat_socket_receive_packet(struct icmp_packet_rr *icmp_packet,
-			       size_t icmp_len)
+void batadv_socket_receive_packet(struct icmp_packet_rr *icmp_packet,
+				  size_t icmp_len)
 {
 	struct socket_client *hash = socket_client_hash[icmp_packet->uid];
 
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.h
index 380ed4c..7b88636 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -24,9 +24,9 @@
 
 #define ICMP_SOCKET "socket"
 
-void bat_socket_init(void);
-int bat_socket_setup(struct bat_priv *bat_priv);
-void bat_socket_receive_packet(struct icmp_packet_rr *icmp_packet,
-			       size_t icmp_len);
+void batadv_socket_init(void);
+int batadv_socket_setup(struct bat_priv *bat_priv);
+void batadv_socket_receive_packet(struct icmp_packet_rr *icmp_packet,
+				  size_t icmp_len);
 
 #endif /* _NET_BATMAN_ADV_ICMP_SOCKET_H_ */
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 8e40836..84dbda5 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -65,7 +65,7 @@ static int __init batman_init(void)
 	if (!bat_event_workqueue)
 		return -ENOMEM;
 
-	bat_socket_init();
+	batadv_socket_init();
 	batadv_debugfs_init();
 
 	register_netdevice_notifier(&batadv_hard_if_notifier);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 5b5feb4..7525e4f 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -289,7 +289,7 @@ static int recv_my_icmp_packet(struct bat_priv *bat_priv,
 
 	/* add data to device queue */
 	if (icmp_packet->msg_type != ECHO_REQUEST) {
-		bat_socket_receive_packet(icmp_packet, icmp_len);
+		batadv_socket_receive_packet(icmp_packet, icmp_len);
 		goto out;
 	}
 
-- 
1.7.9.4
