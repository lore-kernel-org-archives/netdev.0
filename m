From: santosh nayak <santoshprasadnayak@gmail.com>
Subject: [PATCH] netxen: Error return off by one in 'netxen_nic_set_pauseparam()'.
Date: Wed, 20 Jun 2012 12:57:39 +0530
Message-ID: <1340177259-14083-1-git-send-email-santoshprasadnayak@gmail.com>
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Santosh Nayak <santoshprasadnayak@gmail.com>
To: sony.chacko@qlogic.com, rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:41089 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052Ab2FTH14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 03:27:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santosh Nayak <santoshprasadnayak@gmail.com>

There are 'NETXEN_NIU_MAX_GBE_PORTS'  GBE ports. Port indexing starts
from zero. 
Hence we should also return error for "port == NETXEN_NIU_MAX_GBE_PORTS"

Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
---
Destination tree "linux-next"


 .../ethernet/qlogic/netxen/netxen_nic_ethtool.c    |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
index 3973040..d4f179f 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
@@ -489,7 +489,7 @@ netxen_nic_get_pauseparam(struct net_device *dev,
 	int port = adapter->physical_port;
 
 	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
-		if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
+		if ((port < 0) || (port >= NETXEN_NIU_MAX_GBE_PORTS))
 			return;
 		/* get flow control settings */
 		val = NXRD32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port));
@@ -534,7 +534,7 @@ netxen_nic_set_pauseparam(struct net_device *dev,
 	int port = adapter->physical_port;
 	/* read mode */
 	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
-		if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
+		if ((port < 0) || (port >= NETXEN_NIU_MAX_GBE_PORTS))
 			return -EIO;
 		/* set flow control */
 		val = NXRD32(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port));
-- 
1.7.4.4
