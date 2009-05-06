From: Patrick McHardy <kaber@trash.net>
Subject: net-sched: fix bfifo default limit
Date: Wed, 06 May 2009 15:35:12 +0200
Message-ID: <4A019210.5000108@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020405090102080903040304"
To: Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43805 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758518AbZEFNfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 09:35:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020405090102080903040304
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------020405090102080903040304
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

net-sched: fix bfifo default limit

When no limit is given, the bfifo uses a default of tx_queue_len * mtu.
Packets handled by qdiscs include the link layer header, so this should
be taken into account, similar to what other qdiscs do.

Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 92cfc9d..69188e8 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -51,7 +51,7 @@ static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 		u32 limit = qdisc_dev(sch)->tx_queue_len ? : 1;
 
 		if (sch->ops == &bfifo_qdisc_ops)
-			limit *= qdisc_dev(sch)->mtu;
+			limit *= psched_mtu(qdisc_dev(sch));
 
 		q->limit = limit;
 	} else {

--------------020405090102080903040304--
