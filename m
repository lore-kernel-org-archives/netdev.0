From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 1/4] f_phonet: dev_kfree_skb instead of dev_kfree_skb_any in TX callback
Date: Mon,  6 Apr 2009 18:02:54 +0300
Message-ID: <1239030177-28783-1-git-send-email-remi.denis-courmont@nokia.com>
References: <200904061758.58057.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:43726 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbZDFPEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 11:04:23 -0400
In-Reply-To: <200904061758.58057.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Network device TX is never run in IRQ context, and skb is freed outside
of the IRQ-disabling spin lock. So checking for IRQ was a waste of time
here.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 drivers/usb/gadget/f_phonet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phone=
t.c
index c1abeb8..54451ee 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -255,7 +255,7 @@ out_unlock:
 	spin_unlock_irqrestore(&port->lock, flags);
 out:
 	if (unlikely(skb)) {
-		dev_kfree_skb_any(skb);
+		dev_kfree_skb(skb);
 		dev->stats.tx_dropped++;
 	}
 	return 0;
--=20
1.5.6.5

