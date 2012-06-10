From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: [PATCH] af_packet: use sizeof instead of constant in spkt_device
Date: Sun, 10 Jun 2012 20:59:28 +0200
Message-ID: <4FD4EE90.1070302@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34588 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898Ab2FJTTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2012 15:19:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This small patch removes access to the last element of the spkt_device
array through a constant. Instead, it is accessed by sizeof() to respect
possible changes in if_packet.h.

Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
---
 net/packet/af_packet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 0f66174..06ff8e1 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1476,7 +1476,7 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 	 *	Find the device first to size check it
 	 */
 
-	saddr->spkt_device[13] = 0;
+	saddr->spkt_device[sizeof(saddr->spkt_device) - 1] = 0;
 retry:
 	rcu_read_lock();
 	dev = dev_get_by_name_rcu(sock_net(sk), saddr->spkt_device);
