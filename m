From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [PATCH] netxen : Error return off by one for XG port.
Date: Wed, 20 Jun 2012 08:06:04 -0500
Message-ID: <13A253B3F9BEFE43B93C09CF75F63CAA81A886EF1A@MNEXMB1.qlogic.org>
References: <1340189578-18308-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: santosh nayak <santoshprasadnayak@gmail.com>,
	Sony Chacko <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.199.154.139] ([213.199.154.139]:4818 "EHLO
	db3outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755583Ab2FTNIP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 09:08:15 -0400
In-Reply-To: <1340189578-18308-1-git-send-email-santoshprasadnayak@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

______________________________________
From: santosh nayak [santoshprasadnayak@gmail.com]
Sent: Wednesday, June 20, 2012 4:22 PM
To: Sony Chacko; Rajesh Borundia
Cc: netdev; kernel-janitors@vger.kernel.org; Santosh Nayak
Subject: [PATCH] netxen : Error return off by one for XG port.

From: Santosh Nayak <santoshprasadnayak@gmail.com>

There are  NETXEN_NIU_MAX_XG_PORTS ports.
Port indexing starts from zero.
Hence we should also return error for  'port == NETXEN_NIU_MAX_XG_PORTS'.

Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
---
 .../ethernet/qlogic/netxen/netxen_nic_ethtool.c    |    4 ++--
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
index d4f179f..9103e3e 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
@@ -511,7 +511,7 @@ netxen_nic_get_pauseparam(struct net_device *dev,
                                break;
                }
        } else if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
-               if ((port < 0) || (port > NETXEN_NIU_MAX_XG_PORTS))
+               if ((port < 0) || (port >= NETXEN_NIU_MAX_XG_PORTS))
                        return;
                pause->rx_pause = 1;
                val = NXRD32(adapter, NETXEN_NIU_XG_PAUSE_CTL);
@@ -577,7 +577,7 @@ netxen_nic_set_pauseparam(struct net_device *dev,
                }
                NXWR32(adapter, NETXEN_NIU_GB_PAUSE_CTL, val);
        } else if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
-               if ((port < 0) || (port > NETXEN_NIU_MAX_XG_PORTS))
+               if ((port < 0) || (port >= NETXEN_NIU_MAX_XG_PORTS))
                        return -EIO;
                val = NXRD32(adapter, NETXEN_NIU_XG_PAUSE_CTL);
                if (port == 0) {
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
index de96a94..946160f 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
@@ -365,7 +365,7 @@ static int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
        if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
                return 0;

-       if (port > NETXEN_NIU_MAX_XG_PORTS)
+       if (port >= NETXEN_NIU_MAX_XG_PORTS)
                return -EINVAL;

        mac_cfg = 0;
@@ -392,7 +392,7 @@ static int netxen_p2_nic_set_promisc(struct netxen_adapter *adapter, u32 mode)
        u32 port = adapter->physical_port;
        u16 board_type = adapter->ahw.board_type;

-       if (port > NETXEN_NIU_MAX_XG_PORTS)
+       if (port >= NETXEN_NIU_MAX_XG_PORTS)
                return -EINVAL;

        mac_cfg = NXRD32(adapter, NETXEN_NIU_XGE_CONFIG_0 + (0x10000 * port));
--
1.7.4.4

Looks ok to me.

Rajesh
