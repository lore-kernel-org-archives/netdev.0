From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 15/20] batman-adv: Prefix icmp_socket local static functions with batadv_
Date: Mon, 25 Jun 2012 08:54:39 +0200
Message-ID: <1340607284-29950-16-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:30444 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754753Ab2FYGyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:54:50 -0400
In-Reply-To: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

All non-static symbols of batman-adv were prefixed with batadv_ to avoid
collisions with other symbols of the kernel. Other symbols of batman-adv
should use the same prefix to keep the naming scheme consistent.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/icmp_socket.c |   66 ++++++++++++++++++++++--------------------
 1 file changed, 34 insertions(+), 32 deletions(-)

diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index a3e80b6..b285c31 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -26,18 +26,18 @@
 #include "originator.h"
 #include "hard-interface.h"
 
-static struct socket_client *socket_client_hash[256];
+static struct socket_client *batadv_socket_client_hash[256];
 
-static void bat_socket_add_packet(struct socket_client *socket_client,
-				  struct icmp_packet_rr *icmp_packet,
-				  size_t icmp_len);
+static void batadv_socket_add_packet(struct socket_client *socket_client,
+				     struct icmp_packet_rr *icmp_packet,
+				     size_t icmp_len);
 
 void batadv_socket_init(void)
 {
-	memset(socket_client_hash, 0, sizeof(socket_client_hash));
+	memset(batadv_socket_client_hash, 0, sizeof(batadv_socket_client_hash));
 }
 
-static int bat_socket_open(struct inode *inode, struct file *file)
+static int batadv_socket_open(struct inode *inode, struct file *file)
 {
 	unsigned int i;
 	struct socket_client *socket_client;
@@ -49,14 +49,14 @@ static int bat_socket_open(struct inode *inode, struct file *file)
 	if (!socket_client)
 		return -ENOMEM;
 
-	for (i = 0; i < ARRAY_SIZE(socket_client_hash); i++) {
-		if (!socket_client_hash[i]) {
-			socket_client_hash[i] = socket_client;
+	for (i = 0; i < ARRAY_SIZE(batadv_socket_client_hash); i++) {
+		if (!batadv_socket_client_hash[i]) {
+			batadv_socket_client_hash[i] = socket_client;
 			break;
 		}
 	}
 
-	if (i == ARRAY_SIZE(socket_client_hash)) {
+	if (i == ARRAY_SIZE(batadv_socket_client_hash)) {
 		pr_err("Error - can't add another packet client: maximum number of clients reached\n");
 		kfree(socket_client);
 		return -EXFULL;
@@ -75,7 +75,7 @@ static int bat_socket_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static int bat_socket_release(struct inode *inode, struct file *file)
+static int batadv_socket_release(struct inode *inode, struct file *file)
 {
 	struct socket_client *socket_client = file->private_data;
 	struct socket_packet *socket_packet;
@@ -92,7 +92,7 @@ static int bat_socket_release(struct inode *inode, struct file *file)
 		kfree(socket_packet);
 	}
 
-	socket_client_hash[socket_client->index] = NULL;
+	batadv_socket_client_hash[socket_client->index] = NULL;
 	spin_unlock_bh(&socket_client->lock);
 
 	kfree(socket_client);
@@ -101,8 +101,8 @@ static int bat_socket_release(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static ssize_t bat_socket_read(struct file *file, char __user *buf,
-			       size_t count, loff_t *ppos)
+static ssize_t batadv_socket_read(struct file *file, char __user *buf,
+				  size_t count, loff_t *ppos)
 {
 	struct socket_client *socket_client = file->private_data;
 	struct socket_packet *socket_packet;
@@ -144,8 +144,8 @@ static ssize_t bat_socket_read(struct file *file, char __user *buf,
 	return packet_len;
 }
 
-static ssize_t bat_socket_write(struct file *file, const char __user *buff,
-				size_t len, loff_t *off)
+static ssize_t batadv_socket_write(struct file *file, const char __user *buff,
+				   size_t len, loff_t *off)
 {
 	struct socket_client *socket_client = file->private_data;
 	struct bat_priv *bat_priv = socket_client->bat_priv;
@@ -206,7 +206,8 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 	if (icmp_packet->header.version != COMPAT_VERSION) {
 		icmp_packet->msg_type = PARAMETER_PROBLEM;
 		icmp_packet->header.version = COMPAT_VERSION;
-		bat_socket_add_packet(socket_client, icmp_packet, packet_len);
+		batadv_socket_add_packet(socket_client, icmp_packet,
+					 packet_len);
 		goto free_skb;
 	}
 
@@ -239,7 +240,7 @@ static ssize_t bat_socket_write(struct file *file, const char __user *buff,
 
 dst_unreach:
 	icmp_packet->msg_type = DESTINATION_UNREACHABLE;
-	bat_socket_add_packet(socket_client, icmp_packet, packet_len);
+	batadv_socket_add_packet(socket_client, icmp_packet, packet_len);
 free_skb:
 	kfree_skb(skb);
 out:
@@ -252,7 +253,7 @@ out:
 	return len;
 }
 
-static unsigned int bat_socket_poll(struct file *file, poll_table *wait)
+static unsigned int batadv_socket_poll(struct file *file, poll_table *wait)
 {
 	struct socket_client *socket_client = file->private_data;
 
@@ -264,13 +265,13 @@ static unsigned int bat_socket_poll(struct file *file, poll_table *wait)
 	return 0;
 }
 
-static const struct file_operations fops = {
+static const struct file_operations batadv_fops = {
 	.owner = THIS_MODULE,
-	.open = bat_socket_open,
-	.release = bat_socket_release,
-	.read = bat_socket_read,
-	.write = bat_socket_write,
-	.poll = bat_socket_poll,
+	.open = batadv_socket_open,
+	.release = batadv_socket_release,
+	.read = batadv_socket_read,
+	.write = batadv_socket_write,
+	.poll = batadv_socket_poll,
 	.llseek = no_llseek,
 };
 
@@ -282,7 +283,7 @@ int batadv_socket_setup(struct bat_priv *bat_priv)
 		goto err;
 
 	d = debugfs_create_file(ICMP_SOCKET, S_IFREG | S_IWUSR | S_IRUSR,
-				bat_priv->debug_dir, bat_priv, &fops);
+				bat_priv->debug_dir, bat_priv, &batadv_fops);
 	if (!d)
 		goto err;
 
@@ -292,9 +293,9 @@ err:
 	return -ENOMEM;
 }
 
-static void bat_socket_add_packet(struct socket_client *socket_client,
-				  struct icmp_packet_rr *icmp_packet,
-				  size_t icmp_len)
+static void batadv_socket_add_packet(struct socket_client *socket_client,
+				     struct icmp_packet_rr *icmp_packet,
+				     size_t icmp_len)
 {
 	struct socket_packet *socket_packet;
 
@@ -312,7 +313,7 @@ static void bat_socket_add_packet(struct socket_client *socket_client,
 	/* while waiting for the lock the socket_client could have been
 	 * deleted
 	 */
-	if (!socket_client_hash[icmp_packet->uid]) {
+	if (!batadv_socket_client_hash[icmp_packet->uid]) {
 		spin_unlock_bh(&socket_client->lock);
 		kfree(socket_packet);
 		return;
@@ -338,8 +339,9 @@ static void bat_socket_add_packet(struct socket_client *socket_client,
 void batadv_socket_receive_packet(struct icmp_packet_rr *icmp_packet,
 				  size_t icmp_len)
 {
-	struct socket_client *hash = socket_client_hash[icmp_packet->uid];
+	struct socket_client *hash;
 
+	hash = batadv_socket_client_hash[icmp_packet->uid];
 	if (hash)
-		bat_socket_add_packet(hash, icmp_packet, icmp_len);
+		batadv_socket_add_packet(hash, icmp_packet, icmp_len);
 }
-- 
1.7.9.4
