From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 0/9] net: bcmgenet: start/stop sequence refinement
Date: Wed, 25 Oct 2017 15:04:10 -0700
Message-ID: <20171025220419.24951-1-opendmb@gmail.com>
Cc: Doug Berger <opendmb@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit set is the result of an investigation into an issue that
occurred when bringing the interface up and down repeatedly with an
external 100BASE-T PHY. In some cases the MAC would experience mass
receive packet duplication that could in rare cases lead to a stall
from overflow.  The fix for this is contained in the third commit.

The first 3 commits represent bug fixes that should be applied to the
net repository and are candidates for backporting to stable releases.
The remaining commits are enhancements which is why the set is being
submitted to net-next but they are implemented on top of the fixes.

The first fix is provided as justification for why the set isn't
split between a net submission and a net-next submission.

Doug Berger (9):
  net: bcmgenet: correct bad merge
  net: bcmgenet: prevent duplicate calls of bcmgenet_dma_teardown
  net: bcmgenet: enable loopback during UniMAC sw_reset
  net: bcmgenet: move NAPI initialization to ring initialization
  net: bcmgenet: cleanup ring interrupt masking and unmasking
  net: bcmgenet: rework bcmgenet_netif_start and bcmgenet_netif_stop
  net: bcmgenet: relax lock constraints to reduce IRQ latency
  Revert "net: bcmgenet: Software reset EPHY after power on"
  net: bcmgenet: use dev->phydev instead of priv->phydev

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 269 +++++++------------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |   2 -
 drivers/net/ethernet/broadcom/genet/bcmmii.c   |  33 +--
 3 files changed, 83 insertions(+), 221 deletions(-)

-- 
2.14.1
