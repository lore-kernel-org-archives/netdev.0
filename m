From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH] Phonet: fix accounting race between gprs_writeable() and gprs_xmit()
Date: Mon,  1 Jun 2009 13:35:16 +0300
Message-ID: <1243852516-16597-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:36957 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755705AbZFAKeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 06:34:13 -0400
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n51AXuiV006627
	for <netdev@vger.kernel.org>; Mon, 1 Jun 2009 13:34:09 +0300
Received: from localhost.localdomain (esdhcp037217.research.nokia.com [172.21.37.217])
	by mgw-sa01.ext.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n51AXtM1022005
	for <netdev@vger.kernel.org>; Mon, 1 Jun 2009 13:33:56 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

In the unlikely event that gprs_writeable() and gprs_xmit() check for
writeability at the same, we could stop the device queue forever.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep-gprs.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index 4aa8885..851f6a3 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -212,8 +212,9 @@ static int gprs_xmit(struct sk_buff *skb, struct ne=
t_device *dev)
 		dev->stats.tx_bytes +=3D len;
 	}
=20
-	if (!pep_writeable(sk))
-		netif_stop_queue(dev);
+	netif_stop_queue(dev);
+	if (pep_writeable(sk))
+		netif_wake_queue(dev);
 	return 0;
 }
=20
--=20
1.6.0.4

