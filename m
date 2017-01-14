From: Basil Gunn <basil@pacabunga.com>
Subject: [PATCH 1/1] ax25: Fix segfault after sock connection timeout
Date: Sat, 14 Jan 2017 12:18:55 -0800
Message-ID: <20170114121855.62254455@brox.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, Jeremy McDermond <mcdermj@xenotropic.com>,
        f6bvp <f6bvp@free.fr>
To: Joerg Reuter <jreuter@yaina.de>,
        Ralf Baechle <ralf@linux-mips.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ax.25 socket connection timed out & the sock struct has been
previously taken down ie. sock struct is now a NULL pointer. Checking
the sock_flag causes the segfault.  Check if the socket struct pointer
is NULL before checking sock_flag. This segfault is seen in
timed out netrom connections.

Please submit to -stable.

Signed-off-by: Basil Gunn <basil@pacabunga.com>
---

diff --git a/net/ax25/ax25_subr.c b/net/ax25/ax25_subr.c
index 4855d18..038b109 100644
--- a/net/ax25/ax25_subr.c
+++ b/net/ax25/ax25_subr.c
@@ -264,7 +264,7 @@ void ax25_disconnect(ax25_cb *ax25, int reason)
 {
 	ax25_clear_queues(ax25);

-	if (!sock_flag(ax25->sk, SOCK_DESTROY))
+	if (!ax25->sk || !sock_flag(ax25->sk, SOCK_DESTROY))
 		ax25_stop_heartbeat(ax25);
 	ax25_stop_t1timer(ax25);
 	ax25_stop_t2timer(ax25);
