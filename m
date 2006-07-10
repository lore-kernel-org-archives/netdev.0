From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NETROM] Drop lock before calling nr_destroy_socket
Date: Tue, 11 Jul 2006 00:25:45 +0100
Message-ID: <20060710232545.GA8866@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:64900 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S965323AbWGJXZo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 19:25:44 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nr_destroy_socket takes the socket lock itself so it should better be
called with the socket unlocked.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---

diff --git a/net/netrom/nr_timer.c b/net/netrom/nr_timer.c
index 75b72d3..ddba1c1 100644
--- a/net/netrom/nr_timer.c
+++ b/net/netrom/nr_timer.c
@@ -138,8 +138,8 @@ static void nr_heartbeat_expiry(unsigned
 		if (sock_flag(sk, SOCK_DESTROY) ||
 		    (sk->sk_state == TCP_LISTEN && sock_flag(sk, SOCK_DEAD))) {
 			sock_hold(sk);
-			nr_destroy_socket(sk);
 			bh_unlock_sock(sk);
+			nr_destroy_socket(sk);
 			sock_put(sk);
 			return;
 		}
