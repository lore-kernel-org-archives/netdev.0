From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net v2 0/5] net: fix phydev reference leaks
Date: Thu, 24 Nov 2016 19:21:26 +0100
Message-ID: <1480011691-13278-1-git-send-email-johan@kernel.org>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Timur Tabi <timur@codeaurora.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Johan Hovold <johan@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series fixes a number of phydev reference leaks (and one of_node
leak) due to failure to put the reference taken by of_phy_find_device().

Note that I did not try to fix drivers/net/phy/xilinx_gmii2rgmii.c which
still leaks a reference.

Against net but should apply just as fine to net-next.

Thanks,
Johan

v2: 
 - use put_device() instead of phy_dev_free() to put the references
   taken in net/dsa (patch 1/4).
 - add four new patches fixing similar leaks


Johan Hovold (5):
  net: dsa: fix fixed-link-phy device leaks
  net: bcmgenet: fix phydev reference leak
  net: fsl/fman: fix phydev reference leak
  net: fsl/fman: fix fixed-link-phydev reference leak
  net: qcom/emac: fix of_node and phydev leaks

 drivers/net/ethernet/broadcom/genet/bcmmii.c     | 4 +++-
 drivers/net/ethernet/freescale/fman/fman_memac.c | 3 +++
 drivers/net/ethernet/freescale/fman/mac.c        | 2 ++
 drivers/net/ethernet/qualcomm/emac/emac-phy.c    | 1 +
 drivers/net/ethernet/qualcomm/emac/emac.c        | 4 ++++
 net/dsa/dsa.c                                    | 5 ++++-
 6 files changed, 17 insertions(+), 2 deletions(-)

-- 
2.7.3
