From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH v3 3/3] sctp_diag: Respect ss adding TCPF_CLOSE to idiag_states
Date: Thu,  4 Aug 2016 12:11:57 +0200
Message-ID: <1470305517-31880-4-git-send-email-phil@nwl.cc>
References: <1470305517-31880-1-git-send-email-phil@nwl.cc>
Cc: Xin Long <lucien.xin@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41509 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754205AbcHDKND (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 06:13:03 -0400
In-Reply-To: <1470305517-31880-1-git-send-email-phil@nwl.cc>
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
index f728ef04a7b2d..bb691538adc8e 100644
--- a/net/sctp/sctp_diag.c
+++ b/net/sctp/sctp_diag.c
@@ -356,7 +356,7 @@ static int sctp_ep_dump(struct sctp_endpoint *ep, void *p)
 	if (cb->args[4] < cb->args[1])
 		goto next;
 
-	if ((r->idiag_states & ~TCPF_LISTEN) && !list_empty(&ep->asocs))
+	if (!(r->idiag_states & TCPF_LISTEN) && !list_empty(&ep->asocs))
 		goto next;
 
 	if (r->sdiag_family != AF_UNSPEC &&
@@ -471,7 +471,7 @@ skip:
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
