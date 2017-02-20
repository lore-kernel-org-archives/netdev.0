From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v3 00/12]  net: ethernet: aquantia: improvements and fixes
Date: Mon, 20 Feb 2017 14:41:42 +0300
Message-ID: <cover.1487590641.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0065.outbound.protection.outlook.com ([104.47.42.65]:11800
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751341AbdBTLml (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 06:42:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

The following patchset contains improvements and fixes for aQuantia
AQtion ethernet driver from net-next tree.

Most fixes are based on the comments from Lino Sanfilippo.

Sanity testing was performed on real HW. No regression found.

v1->v2 :1)Removed buffers copying.
	2)Fixed dma error handling.

v2->v3 :1)Fixes for aq_ndev_change_mtu:
	-Use core MTU checking for min_mtu.
	-Removed extra new_mtu assigment.
	2)Reverse XMAS tree in aq_ring_rx_fill.

Please review.
Thanks.
Pavel Belous (12):
  net: ethernet: aquantia: Removed extra assignment for skb->dev.
  net: ethernet: aquantia: Removed busy_count field.
  net: ethernet: aquantia: Fixes for aq_ndev_change_mtu
  net: ethernet: aquantia: Using module_pci_driver.
  net: ethernet: aquantia: Superfluous initialization of "err".
  net: ethernet: aquantia: Fixed missing rtnl_unlock.
  net: ethernet: aquantia: Using NETDEV_TX_OK instead 0.
  net: ethernet: aquantia: Null pointer check for aq_nic_ndev_alloc.
  net: ethernet: aquantia: Call netdev_register after all initialized.
  net: ethernet: aquantia: Fixed incorrect buff->len calculation.
  net: ethernet: aquantia: Fixed memory allocation if
    AQ_CFG_RX_FRAME_MAX > 1 page.
  net: ethernet: aquantia: Copying tx buffers is not needed.

 drivers/net/ethernet/aquantia/atlantic/aq_main.c   |  40 +---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c    | 206 +++++++++++----------
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c   |  24 +--
 drivers/net/ethernet/aquantia/atlantic/aq_ring.h   |   3 -
 drivers/net/ethernet/aquantia/atlantic/aq_utils.h  |   1 -
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c  |   4 +-
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c  |   4 +-
 7 files changed, 122 insertions(+), 160 deletions(-)

-- 
2.7.4
