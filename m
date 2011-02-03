From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 3/3] r8169: prevent RxFIFO induced loops in the irq handler.
Date: Thu, 3 Feb 2011 18:26:56 +0100
Message-ID: <20110203172656.GD9024@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ivan Vecera <ivecera@redhat.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36855 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756196Ab1BCR3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 12:29:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While the RxFIFO interruption is masked for most 8168, nothing prevents
it to appear in the irq status word. This is no excuse to crash.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Ivan Vecera <ivecera@redhat.com>
Cc: Hayes <hayeswang@realtek.com>
---
 drivers/net/r8169.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 40dabe2..59ccf0c 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4650,6 +4650,15 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 				netif_stop_queue(dev);
 				rtl8169_tx_timeout(dev);
 				goto done;
+			/* Testers needed. */
+			case RTL_GIGA_MAC_VER_17:
+			case RTL_GIGA_MAC_VER_19:
+			case RTL_GIGA_MAC_VER_20:
+			case RTL_GIGA_MAC_VER_21:
+			case RTL_GIGA_MAC_VER_23:
+			case RTL_GIGA_MAC_VER_24:
+			case RTL_GIGA_MAC_VER_27:
+			case RTL_GIGA_MAC_VER_28:
 			/* Experimental science. Pktgen proof. */
 			case RTL_GIGA_MAC_VER_12:
 			case RTL_GIGA_MAC_VER_25:
-- 
1.7.3.5

