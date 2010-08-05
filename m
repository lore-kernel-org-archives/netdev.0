From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 37/42] drivers/net/hamradio: Adjust confusing if indentation
Date: Thu, 5 Aug 2010 22:28:12 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008052227520.31692@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Joerg Reuter <jreuter@yaina.de>,
	Klaus Kudielka <klaus.kudielka@ieee.org>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:58167 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933006Ab0HEU2O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 16:28:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Indent the branch of an if.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r disable braces4@
position p1,p2;
statement S1,S2;
@@

(
if (...) { ... }
|
if (...) S1@p1 S2@p2
)

@script:python@
p1 << r.p1;
p2 << r.p2;
@@

if (p1[0].column == p2[0].column):
  cocci.print_main("branch",p1)
  cocci.print_secs("after",p2)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/hamradio/scc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index 9f64c86..3365581 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1069,7 +1069,8 @@ static void scc_tx_done(struct scc_channel *scc)
 		case KISS_DUPLEX_LINK:
 			scc->stat.tx_state = TXS_IDLE2;
 			if (scc->kiss.idletime != TIMER_OFF)
-			scc_start_tx_timer(scc, t_idle, scc->kiss.idletime*100);
+				scc_start_tx_timer(scc, t_idle,
+						   scc->kiss.idletime*100);
 			break;
 		case KISS_DUPLEX_OPTIMA:
 			scc_notify(scc, HWEV_ALL_SENT);
