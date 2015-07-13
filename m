From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH v2] NET: AX.25: Stop heartbeat timer on disconnect.
Date: Mon, 13 Jul 2015 11:38:24 +0200
Message-ID: <20150713093824.GA32732@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Richard Stearn <richard@rns-stearn.demon.co.uk>,
	f6bvp <f6bvp@free.fr>, Thomas Osterried <thomas@osterried.de>,
	linux-hams@vger.kernel.org, stable@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Stearn <richard@rns-stearn.demon.co.uk>

This may result in a kernel panic.  The bug has always existed but
somehow we've run out of luck now and it bites.

Signed-off-by: Richard Stearn <richard@rns-stearn.demon.co.uk>
Cc: stable@vger.kernel.org	# all branches
Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
---
v2: Correctly attribute the patch to Richard Stearn in the From: line

 net/ax25/ax25_subr.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ax25/ax25_subr.c b/net/ax25/ax25_subr.c
index 1997538..3b78e84 100644
--- a/net/ax25/ax25_subr.c
+++ b/net/ax25/ax25_subr.c
@@ -264,6 +264,7 @@ void ax25_disconnect(ax25_cb *ax25, int reason)
 {
 	ax25_clear_queues(ax25);
 
+	ax25_stop_heartbeat(ax25);
 	ax25_stop_t1timer(ax25);
 	ax25_stop_t2timer(ax25);
 	ax25_stop_t3timer(ax25);

----- End forwarded message -----

  Ralf
