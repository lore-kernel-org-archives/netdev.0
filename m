From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: [PATCH 2.6.23-rc8-mm2] Fix a compile problem in macb.c
Date: Tue,  2 Oct 2007 17:23:23 +0200
Message-ID: <1191338603393-git-send-email-hskinnemoen@atmel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	=?utf-8?q?Hans-J=C3=BCrgen=20Koch?= <hjk@linutronix.de>,
	Haavard Skinnemoen <hskinnemoen@atmel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:51406 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751985AbXJBPYH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 11:24:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Hans-J=C3=BCrgen Koch <hjk@linutronix.de>

Compiling macb.c fails because the type of parameter 2 of macb_poll()
was changed from int* to int. Furthermore, a local variable was removed
but was still used inside the function. This patch fixes it.

Signed-off-by: Hans J. Koch <hjk@linutronix.de>
Signed-off-by: Haavard Skinnemoen <hskinnemoen@atmel.com>
---
 drivers/net/macb.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index c28a0a4..047ea7b 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -492,7 +492,7 @@ static int macb_poll(struct napi_struct *napi, int =
budget)
 	}
=20
 	dev_dbg(&bp->pdev->dev, "poll: status =3D %08lx, budget =3D %d\n",
-		(unsigned long)status, *budget);
+		(unsigned long)status, budget);
=20
 	if (!(status & MACB_BIT(REC))) {
 		dev_warn(&bp->pdev->dev,
@@ -503,7 +503,7 @@ static int macb_poll(struct napi_struct *napi, int =
budget)
 	}
=20
 	work_done =3D macb_rx(bp, budget);
-	if (work_done < orig_budget)
+	if (work_done < budget)
 		netif_rx_complete(dev, napi);
=20
 	/*
--=20
1.5.3.1

