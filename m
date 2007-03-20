From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH 24/31] [CCID3]: More to see in dccp_probe
Date: Tue, 20 Mar 2007 20:17:15 -0300
Message-ID: <20070320231715.GM17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:40598 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933846AbXCTXRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:17:19 -0400
Received: by wx-out-0506.google.com with SMTP id h31so67362wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:17:19 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds a few more fields of interest to /proc/net/dccpprobe, the following output ensues:

1           2          3           4     5  6     7   8        9        10   11
sec.usec   src:sport   dst:dport   size  s  rtt   p   X_calc   X_recv   X    t_ipi

Also made the formatting consistent.

Scripts that go with this can be downloaded from http://139.133.210.30/users/gerrit/dccp/dccp_probe/

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/probe.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index 3b1f509..1f5e3ba 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -90,15 +90,18 @@ static int jdccp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (port == 0 || ntohs(inet->dport) == port ||
 	    ntohs(inet->sport) == port) {
 		if (hctx)
-			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %d %d %d %d\n",
-			   NIPQUAD(inet->saddr), ntohs(inet->sport),
-			   NIPQUAD(inet->daddr), ntohs(inet->dport), size,
-			   hctx->ccid3hctx_s, hctx->ccid3hctx_rtt,
-			   hctx->ccid3hctx_p, hctx->ccid3hctx_t_ipi);
+			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %d %d %d %u "
+			       "%llu %llu %d\n",
+			       NIPQUAD(inet->saddr), ntohs(inet->sport),
+			       NIPQUAD(inet->daddr), ntohs(inet->dport), size,
+			       hctx->ccid3hctx_s, hctx->ccid3hctx_rtt,
+			       hctx->ccid3hctx_p, hctx->ccid3hctx_x_calc,
+			       hctx->ccid3hctx_x_recv >> 6,
+			       hctx->ccid3hctx_x >> 6, hctx->ccid3hctx_t_ipi);
 		else
 			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d\n",
-			   NIPQUAD(inet->saddr), ntohs(inet->sport),
-			   NIPQUAD(inet->daddr), ntohs(inet->dport), size);
+			       NIPQUAD(inet->saddr), ntohs(inet->sport),
+			       NIPQUAD(inet->daddr), ntohs(inet->dport), size);
 	}
 
 	jprobe_return();
-- 
1.5.0.3

