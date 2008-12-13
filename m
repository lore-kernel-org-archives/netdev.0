From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 11/11] rpc/rdma: goto instead of copypaste
Date: Sat, 13 Dec 2008 21:21:22 +0200
Message-ID: <1229196082-4162-12-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1229196082-4162-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-7-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-8-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-9-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-10-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-11-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49496 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbYLMTV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 14:21:26 -0500
In-Reply-To: <1229196082-4162-11-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[I really don't have a clue who I should cc this to]

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtr=
dma/svc_rdma_recvfrom.c
index a475657..629a287 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -646,8 +646,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	ret =3D rdma_read_xdr(rdma_xprt, rmsgp, rqstp, ctxt);
 	if (ret > 0) {
 		/* read-list posted, defer until data received from client. */
-		svc_xprt_received(xprt);
-		return 0;
+		goto defer;
 	}
 	if (ret < 0) {
 		/* Post of read-list failed, free context. */
@@ -679,6 +678,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 	 * close bit and call svc_xprt_delete
 	 */
 	set_bit(XPT_CLOSE, &xprt->xpt_flags);
+defer:
 	svc_xprt_received(xprt);
 	return 0;
 }
--=20
1.5.2.2

