From: Yi Zou <yi.zou@intel.com>
Subject: [PATCH v2] net: group FCoE related feature flags
Date: Mon, 09 May 2011 14:53:27 -0700
Message-ID: <20110509215133.4346.14504.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, jeffrey.t.kirsher@intel.com,
	devel@open-fcoe.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35389 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752937Ab1EIVie (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 17:38:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw's patch (http://patchwork.ozlabs.org/patch/94=
421/) fixes the
issue (http://patchwork.ozlabs.org/patch/94188/) about not populating F=
CoE related
flags correctly on vlan devices. However, only NETIF_F_FCOE_CRC is part=
 of the
NETIF_F_ALL_TX_OFFLOADS right now, where weed NETIF_F_FCOE_MTU and NETI=
=46_F_FSO
as well.

Therefore, add NETIF_F_ALL_FCOE to indicate feature flags used by FCoE =
TX offloads.
These include NETIF_F_FCOE_CRC, NETIF_F_FCOE_MTU, and NETIF_F_FSO and a=
dd them to
be part of NETIF_F_ALL_TX_OFFLOADS. This would eventually make sure all=
 FCoE needed
flags are populated properly to vlan devices.

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 include/linux/netdevice.h |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e7244ed..00d650c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1097,10 +1097,14 @@ struct net_device {
=20
 #define NETIF_F_ALL_TSO 	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN=
)
=20
+#define NETIF_F_ALL_FCOE	(NETIF_F_FCOE_CRC | NETIF_F_FCOE_MTU | \
+				 NETIF_F_FSO)
+
 #define NETIF_F_ALL_TX_OFFLOADS	(NETIF_F_ALL_CSUM | NETIF_F_SG | \
 				 NETIF_F_FRAGLIST | NETIF_F_ALL_TSO | \
 				 NETIF_F_HIGHDMA | \
-				 NETIF_F_SCTP_CSUM | NETIF_F_FCOE_CRC)
+				 NETIF_F_SCTP_CSUM | \
+				 NETIF_F_ALL_FCOE)
=20
 	/*
 	 * If one device supports one of these features, then enable them

