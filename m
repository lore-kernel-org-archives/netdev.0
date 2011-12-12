From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 11/11] batman-adv: Only write requested number of byte to user buffer
Date: Mon, 12 Dec 2011 19:31:55 +0800
Message-ID: <1323689516-24427-12-git-send-email-lindner_marek@yahoo.de>
References: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm15.bullet.mail.ukl.yahoo.com ([217.146.183.189]:34901 "HELO
	nm15.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752546Ab1LLLdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 06:33:16 -0500
In-Reply-To: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Don't write more than the requested number of bytes of an batman-adv icmp
packet to the userspace buffer. Otherwise unrelated userspace memory might get
overridden by the kernel.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/icmp_socket.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/icmp_socket.c b/net/batman-adv/icmp_socket.c
index 3b04fff..d9c1e7b 100644
--- a/net/batman-adv/icmp_socket.c
+++ b/net/batman-adv/icmp_socket.c
@@ -136,10 +136,9 @@ static ssize_t bat_socket_read(struct file *file, char __user *buf,
 
 	spin_unlock_bh(&socket_client->lock);
 
-	error = copy_to_user(buf, &socket_packet->icmp_packet,
-			     socket_packet->icmp_len);
+	packet_len = min(count, socket_packet->icmp_len);
+	error = copy_to_user(buf, &socket_packet->icmp_packet, packet_len);
 
-	packet_len = socket_packet->icmp_len;
 	kfree(socket_packet);
 
 	if (error)
-- 
1.7.5.4
