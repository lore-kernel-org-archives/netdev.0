From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] atarilance: timeout ignored in lance_open()
Date: Sun, 27 Dec 2009 14:26:12 +0100
Message-ID: <4B376074.2060305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752053AbZL0NXY@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With `while (--i > 0)' i reaches 0 after the loop, so upon timeout the
error was not issued.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 drivers/net/atarilance.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index c5721cb..cc9ed86 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -663,7 +663,7 @@ static int lance_open( struct net_device *dev )
 	while (--i > 0)
 		if (DREG & CSR0_IDON)
 			break;
-	if (i < 0 || (DREG & CSR0_ERR)) {
+	if (i <= 0 || (DREG & CSR0_ERR)) {
 		DPRINTK( 2, ( "lance_open(): opening %s failed, i=%d, csr0=%04x\n",
 					  dev->name, i, DREG ));
 		DREG = CSR0_STOP;
