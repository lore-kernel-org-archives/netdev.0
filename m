From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 1/3] atl1e: Allow TX checksum offload and TSO to be
 disabled and reenabled
Date: Wed, 02 Dec 2009 05:09:52 +0000
Message-ID: <1259730592.21651.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Jie Yang <jie.yang@atheros.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52301 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750834AbZLBFJv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 00:09:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
I have no reason for thinking these hardware features may be buggy, but
it is usual practice to allow them to be disabled.

Ben.

 drivers/net/atl1e/atl1e_ethtool.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/atl1e/atl1e_ethtool.c b/drivers/net/atl1e/atl1e_ethtool.c
index 60edb9f..b0fb725 100644
--- a/drivers/net/atl1e/atl1e_ethtool.c
+++ b/drivers/net/atl1e/atl1e_ethtool.c
@@ -394,11 +394,13 @@ static const struct ethtool_ops atl1e_ethtool_ops = {
 	.get_eeprom             = atl1e_get_eeprom,
 	.set_eeprom             = atl1e_set_eeprom,
 	.get_tx_csum            = atl1e_get_tx_csum,
+	.set_tx_csum            = ethtool_op_set_tx_hw_csum,
 	.get_sg                 = ethtool_op_get_sg,
 	.set_sg                 = ethtool_op_set_sg,
 #ifdef NETIF_F_TSO
 	.get_tso                = ethtool_op_get_tso,
 #endif
+	.set_tso                = ethtool_op_set_tso,
 };
 
 void atl1e_set_ethtool_ops(struct net_device *netdev)
-- 
1.6.5.3



