From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH 0/4] adapt DPAA drivers for DSA
Date: Tue, 10 Oct 2017 17:10:14 +0300
Message-ID: <1507644618-32006-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <junote@outlook.com>,
        <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Junote Cai reported that he was not able to get a DSA setup involving the
DPAA/FMAN driver to work and narrowed it down to of_find_net_device_by_node()
call in DSA setup. The initial attempt to fix this by adding of_node to the
platform device results in a second, failed, probing of the FMan MAC driver
against the new platform device created for the DPAA Ethernet driver.
Solve these issues by removing the of_node pointer from the platform device
and changing the net_dev dev to the of_device dev to ensure the DSA init
will be able to find the DPAA net_dev using of_find_net_device_by_node().
Several changes were required to enable this solution: refactoring the
adjust_link (also resulted in lesser, cleaner code) and renaming the fman
kernel modules to keep the legacy udev rules happy.


Madalin Bucur (4):
  fsl/fman: remove of_node
  dpaa_eth: move of_phy_connect() to the eth driver
  dpaa_eth: change device used
  fsl/fman: add dpaa in module names

 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c |  89 +++++++++-------
 drivers/net/ethernet/freescale/fman/Makefile   |  12 +--
 drivers/net/ethernet/freescale/fman/mac.c      | 135 +++++++------------------
 drivers/net/ethernet/freescale/fman/mac.h      |   6 +-
 4 files changed, 99 insertions(+), 143 deletions(-)

-- 
2.1.0
