From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH v2] xen: netback: fix printf format string warning
Date: Mon, 1 Jun 2015 11:30:04 +0100
Message-ID: <1433154604-27997-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <wei.liu2@citrix.com>, Ian Campbell <ian.campbell@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:59207 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751754AbbFAKoz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2015 06:44:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/xen-netback/netback.c: In function =E2=80=98xenvif_tx_build=
_gops=E2=80=99:
drivers/net/xen-netback/netback.c:1253:8: warning: format =E2=80=98%lu=E2=
=80=99 expects argument of type =E2=80=98long unsigned int=E2=80=99, bu=
t argument 5 has type =E2=80=98int=E2=80=99 [-Wformat=3D]
        (txreq.offset&~PAGE_MASK) + txreq.size);
        ^

PAGE_MASK's type can vary by arch, so a cast is needed.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
----
v2: Cast to unsigned long, since PAGE_MASK can vary by arch.
---
 drivers/net/xen-netback/netback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netbac=
k/netback.c
index 4de46aa..0d25943 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1250,7 +1250,7 @@ static void xenvif_tx_build_gops(struct xenvif_qu=
eue *queue,
 			netdev_err(queue->vif->dev,
 				   "txreq.offset: %x, size: %u, end: %lu\n",
 				   txreq.offset, txreq.size,
-				   (txreq.offset&~PAGE_MASK) + txreq.size);
+				   (unsigned long)(txreq.offset&~PAGE_MASK) + txreq.size);
 			xenvif_fatal_tx_err(queue->vif);
 			break;
 		}
--=20
1.7.10.4
