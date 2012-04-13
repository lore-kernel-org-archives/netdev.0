From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 00/37] atl1c: update hardware settings
Date: Fri, 13 Apr 2012 08:14:25 +0800
Message-ID: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This update contains a serial of patches,
most of them are hardware settings related.
register definitions are refined for each patch.

The patches are for following main purpose:
1. improve the PCI Express Interface stability.
2. improve the PHY Link stability.
3. improve the power consumption, like ASPM and PHY Hibernation.
4. imporve the throughput, get same result with alx driver as shown
   in http://linuxfoundation.org/collaborate/workgroups/networking/alx

Following NICs are tested:
AR8131/AR8132/AR8151A/AR8152A/AR8152B

These patches have addressed all sparse and checkpatch warnings.


xiong (37):
  atl1c: update author contact info & company/driver desciption
  atl1c: remove multiple-RX-Q code
  atl1c: remove HDS register
  atl1c: remove VPD register
  atl1c: remove SMB/CMB DMA related code
  atl1c: split 2 32bit registers of TPD to 4 16bit registers
  atl1c: remove code related to rxq 1/2/3
  atl1c: wrong register used to stop TXQ
  atl1c: correct wrong definition of REG_DMA_CTRL
  atl1c: remove dmaw_block
  atl1c: using fixed TXQ configuration for l2cb and l1c
  atl1c: restore max-read-request-size in Device Conrol Register
  atl1c: threshold for ASPM is changed based on chip capability
  atl1c: add module parameter for l1c_wait_until_idle
  atl1c: update right threshold for TSO
  atl1c: remove dmar_dly_cnt and dmaw_dly_cnt
  atl1c: clear PCIE error status in atl1c_reset_pcie
  atl1c: refine reg definition of REG_MASTER_CTRL
  atl1c: clear bit MASTER_CTRL_CLK_SEL_DIS in atl1c_pcie_patch
  atl1c: refine/update ASPM configuration
  atl1c: refine atl1c_pcie_patch
  atl1c: fix WoL(magic) issue for l2cb 1.1
  atl1c: remove MDIO_REG_ADDR_MASK in atl1c_mdio_read/write
  atl1c: remove REG_PHY_STATUS
  atl1c: refine phy-register read/write function
  atl1c: remove PHY contrl in atl1c_reset_pcie
  atl1c: refine SERDES-clock related code
  atl1c: remove PHY polling from atl1c_open
  atl1c: update PHY reset related routine
  atl1c: remove PHY reset/init for link down event
  atl1c: add function atl1c_power_saving
  atl1c: refine start/enable code for MAC module
  atl1c: add PHY link event(up/down) patch
  atl1c: clear WoL status when reset pcie
  atl1c: remove code of closing register writable attribution
  atl1c: refine mac address related code
  atl1c: cancel task when interface closed

 drivers/net/ethernet/atheros/atl1c/atl1c.h         |   57 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c |    3 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c      |  563 ++++++++----
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h      |  999 ++++++++++++--------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |  913 +++++++-----------
 5 files changed, 1339 insertions(+), 1196 deletions(-)

-- 
1.7.7
