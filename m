From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH] xen: netback: fix error printf format string.
Date: Fri, 29 May 2015 17:22:04 +0100
Message-ID: <1432916524-20881-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <wei.liu2@citrix.com>, Ian Campbell <ian.campbell@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:3921 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751854AbbE2Q3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 12:29:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/xen-netback/netback.c: In function =E2=80=98xenvif_tx_build=
_gops=E2=80=99:
drivers/net/xen-netback/netback.c:1253:8: warning: format =E2=80=98%lu=E2=
=80=99 expects argument of type =E2=80=98long unsigned int=E2=80=99, bu=
t argument 5 has type =E2=80=98int=E2=80=99 [-Wformat=3D]
        (txreq.offset&~PAGE_MASK) + txreq.size);
        ^

txreq.offset and .size are uint16_t fields.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netback/netback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netbac=
k/netback.c
index 4de46aa..a3b1cbb 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1248,7 +1248,7 @@ static void xenvif_tx_build_gops(struct xenvif_qu=
eue *queue,
 		/* No crossing a page as the payload mustn't fragment. */
 		if (unlikely((txreq.offset + txreq.size) > PAGE_SIZE)) {
 			netdev_err(queue->vif->dev,
-				   "txreq.offset: %x, size: %u, end: %lu\n",
+				   "txreq.offset: %x, size: %u, end: %u\n",
 				   txreq.offset, txreq.size,
 				   (txreq.offset&~PAGE_MASK) + txreq.size);
 			xenvif_fatal_tx_err(queue->vif);
--=20
1.7.10.4
