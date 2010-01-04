From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: [PATCH] via-velocity: add netpoll functionality for the benefit of
 netconsole
Date: Mon, 04 Jan 2010 19:32:32 +0100
Message-ID: <4B423440.6060807@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	=?ISO-8859-1?Q?St=E9phane_Berth?= =?ISO-8859-1?Q?elot?=
	<sberthelot@emisfr.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay006.isp.belgacom.be ([195.238.6.172]:23099 "EHLO
	mailrelay006.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752457Ab0ADSci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 13:32:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In February 2008, St=E9phane Bertelot submitted a patch to netdev addin=
g
netpoll functionality to the via-velocity driver so that netconsole
could be used with it.

There was no discussion at the time and the patch was not committed to
mainline.

I'd like to try again with this version, which has been ported to the
current code base.

---------------------
This patch is a port to net-next-2.6 of a submission by St=E9phane
Bertelot in February 2008.

Signed-off-by: St=E9phane Berthelot <sberthelot@emisfr.com>
Signed-off-by: Jan Ceuleers <jan.ceuleers@computer.org>
---
 drivers/net/via-velocity.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 4ceb441..90718f5 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2216,6 +2216,20 @@ static irqreturn_t velocity_intr(int irq, void *=
dev_instance)
 }
=20
 /**
+ *	velocity_poll_controller	- netpoll controller
+ *	@dev: network device
+ *
+ *	Used by netconsole and other diagnostic tools to allow network
+ *	i/o with interrupts disabled.
+ */
+static void velocity_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	velocity_intr(dev->irq, dev);
+	enable_irq(dev->irq);
+}
+
+/**
  *	velocity_open		-	interface activation callback
  *	@dev: network layer device to open
  *
@@ -2628,6 +2642,9 @@ static const struct net_device_ops velocity_netde=
v_ops =3D {
 	.ndo_vlan_rx_add_vid	=3D velocity_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	=3D velocity_vlan_rx_kill_vid,
 	.ndo_vlan_rx_register	=3D velocity_vlan_rx_register,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	=3D velocity_poll_controller,
+#endif
 };
=20
 /**
--=20
1.6.3.3

