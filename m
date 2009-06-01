From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 1/3] f_phonet: dev_kfree_skb instead of dev_kfree_skb_any in TX callback
Date: Mon,  1 Jun 2009 14:18:55 +0300
Message-ID: <1243855137-20149-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:52400 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635AbZFALRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 07:17:45 -0400
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n51BHFR3017582
	for <netdev@vger.kernel.org>; Mon, 1 Jun 2009 14:17:39 +0300
Received: from localhost.localdomain (esdhcp037217.research.nokia.com [172.21.37.217])
	by mgw-sa02.ext.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n51BHbXt003855
	for <netdev@vger.kernel.org>; Mon, 1 Jun 2009 14:17:37 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Network device TX is never run in IRQ context, and skb is freed outside
of the IRQ-disabling spin lock. So checking for IRQ was a waste of time
here.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Signed-off-by: Felipe Balbi <felipe.balbi@nokia.com>
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
1.6.0.4

