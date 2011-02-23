From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 1/4] Fix "(unregistered net_device): Features changed" message
Date: Wed, 23 Feb 2011 03:52:28 +0100 (CET)
Message-ID: <73abccc8711b7c846b6af65c7c46ca4ed092e093.1298429033.git.mirq-linux@rere.qmqm.pl>
References: <cover.1298429033.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:47057 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755914Ab1BWCwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 21:52:30 -0500
In-Reply-To: <cover.1298429033.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix netdev_update_features() messages on register time by moving
the call further in register_netdevice(). When
netdev->reg_state !=3D NETREG_REGISTERED, netdev_name() returns
"(unregistered netdevice)" even if the dev's name is already filled.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/dev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 578415c..77e5edb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5483,8 +5483,6 @@ int register_netdevice(struct net_device *dev)
 	if (!(dev->wanted_features & NETIF_F_SG))
 		dev->wanted_features &=3D ~NETIF_F_GSO;
=20
-	netdev_update_features(dev);
-
 	/* Enable GRO and NETIF_F_HIGHDMA for vlans by default,
 	 * vlan_dev_init() will do the dev->features check, so these features
 	 * are enabled only if supported by underlying device.
@@ -5501,6 +5499,8 @@ int register_netdevice(struct net_device *dev)
 		goto err_uninit;
 	dev->reg_state =3D NETREG_REGISTERED;
=20
+	netdev_update_features(dev);
+
 	/*
 	 *	Default initial state at registry is that the
 	 *	device is present.
--=20
1.7.2.3

