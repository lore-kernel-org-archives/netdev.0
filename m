From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 3/3] sctp_diag: Respect ss adding TCPF_CLOSE to idiag_states
Date: Fri, 29 Jul 2016 18:59:40 +0200
Message-ID: <1469811580-32429-4-git-send-email-phil@nwl.cc>
References: <1469811580-32429-1-git-send-email-phil@nwl.cc>
Cc: Xin Long <lucien.xin@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45671 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753312AbcG2RAM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 13:00:12 -0400
In-Reply-To: <1469811580-32429-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 'ss' always adds TCPF_CLOSE to idiag_states flags, sctp_diag can't
rely upon TCPF_LISTEN flag solely being present when listening sockets
are requested.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/sctp/sctp_diag.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
index 0ad6033a7330c..92ae2828189d5 100644
--- a/net/sctp/sctp_diag.c
+++ b/net/sctp/sctp_diag.c
@@ -352,7 +352,7 @@ static int sctp_ep_dump(struct sctp_endpoint *ep, void *p)
 	if (cb->args[4] < cb->args[1])
 		goto next;
 
-	if ((r->idiag_states & ~TCPF_LISTEN) && !list_empty(&ep->asocs))
+	if (!(r->idiag_states & TCPF_LISTEN) && !list_empty(&ep->asocs))
 		goto next;
 
 	if (r->sdiag_family != AF_UNSPEC &&
@@ -467,7 +467,7 @@ skip:
 	 * 3 : to mark if we have dumped the ep info of the current asoc
 	 * 4 : to work as a temporary variable to traversal list
 	 */
-	if (!(idiag_states & ~TCPF_LISTEN))
+	if (!(idiag_states & ~(TCPF_LISTEN | TCPF_CLOSE)))
 		goto done;
 	sctp_for_each_transport(sctp_tsp_dump, net, cb->args[2], &commp);
 done:
-- 
2.8.2
