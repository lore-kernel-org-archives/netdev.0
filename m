From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] TCP : use LIMIT_NETDEBUG in tcp_retransmit_timer()
Date: Mon, 04 Jun 2007 09:13:40 +0200
Message-ID: <4663BBA4.70009@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040501000804080204070708"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:46094 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbXFDHNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 03:13:51 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040501000804080204070708
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

LIMIT_NETDEBUG allows the admin to disable some warning messages (echo 0 
 >/proc/sys/net/core/warnings).

The "TCP: Treason uncloaked!" message can use this facility.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------040501000804080204070708
Content-Type: text/plain;
 name="use_limit_netdebug.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="use_limit_netdebug.patch"

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index e613401..e9b151b 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -292,9 +292,9 @@ static void tcp_retransmit_timer(struct 
 		 * we cannot allow such beasts to hang infinitely.
 		 */
 #ifdef TCP_DEBUG
-		if (net_ratelimit()) {
+		if (1) {
 			struct inet_sock *inet = inet_sk(sk);
-			printk(KERN_DEBUG "TCP: Treason uncloaked! Peer %u.%u.%u.%u:%u/%u shrinks window %u:%u. Repaired.\n",
+			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Treason uncloaked! Peer %u.%u.%u.%u:%u/%u shrinks window %u:%u. Repaired.\n",
 			       NIPQUAD(inet->daddr), ntohs(inet->dport),
 			       inet->num, tp->snd_una, tp->snd_nxt);
 		}

--------------040501000804080204070708--
