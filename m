From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH net] Phonet: fix oops in phonet_address_del() on non-Phonet device
Date: Wed, 26 Nov 2008 14:41:59 +0200
Message-ID: <1227703319-26719-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:21406 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751960AbYKZMmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 07:42:15 -0500
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx09.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mAQCfdDl027322
	for <netdev@vger.kernel.org>; Wed, 26 Nov 2008 06:42:13 -0600
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A NULL dereference would occur when trying to delete an addres from a
network device that does not have any Phonet address.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pn_dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 53be9fc..f93ff8e 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -115,7 +115,7 @@ int phonet_address_del(struct net_device *dev, u8 a=
ddr)
 	pnd =3D __phonet_get(dev);
 	if (!pnd || !test_and_clear_bit(addr >> 2, pnd->addrs))
 		err =3D -EADDRNOTAVAIL;
-	if (bitmap_empty(pnd->addrs, 64))
+	else if (bitmap_empty(pnd->addrs, 64))
 		__phonet_device_free(pnd);
 	spin_unlock_bh(&pndevs.lock);
 	return err;
--=20
1.5.4.3

