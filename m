From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/9] net: of_phy_connect_fixed_link removal
Date: Thu, 22 May 2014 09:47:42 -0700
Message-ID: <1400777271-32199-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Li Yang <leoli@freescale.com>,
	Grant Likely <grant.likely@linaro.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Aida Mynzhasova <aida.mynzhasova@skitlab.ru>,
	Richard Cochran <richardcochran@gmail.com>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	devicetree@vger.kernel.org (open list:OPEN FIRMWARE AND...),
	linux-kernel@vger.kernel.org (open list),
	linuxppc-dev@lists.ozlabs.org (open list:LINUX FOR POWERPC...)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This patch set removes of_phy_connect_fixed_link() from the tree now that
we have a better solution for dealing with fixed PHY (emulated PHY) devices
for drivers that require them.

First two patches update the 'fixed-link' Device Tree binding and drivers to
refere to it.

Patches 3 to 7 update the in-tree network drivers that use
of_phy_connect_fixed_link()

Patch 8 removes of_phy_connect_fixed_link

Patch 9 removes the PowerPC code that parsed the 'fixed-link' property.

Patch 9 can be merged via the net-next tree if the PowerPC folks ack it,
but it really has to be merged after the first 8 patches in order to avoid
breakage.

Florian Fainelli (9):
  Documentation: devicetree: add old and deprecated 'fixed-link'
  Documentation: devicetree: net: refer to fixed-link.txt
  net: bcmgenet: use the new fixed PHY helpers
  net: systemport: use the new fixed PHY helpers
  fs_enet: use the new fixed PHY helpers
  gianfar: use the new fixed PHY helpers
  ucc_geth: use the new fixed PHY helpers
  of: mdio: remove of_phy_connect_fixed_link
  powerpc/fsl: fsl_soc: remove 'fixed-link' parsing code

 .../devicetree/bindings/net/broadcom-bcmgenet.txt  |  2 +-
 .../bindings/net/broadcom-systemport.txt           |  2 +-
 .../devicetree/bindings/net/fixed-link.txt         | 12 +++++++
 .../devicetree/bindings/net/fsl-tsec-phy.txt       |  5 +--
 arch/powerpc/sysdev/fsl_soc.c                      | 32 ------------------
 drivers/net/ethernet/broadcom/bcmsysport.c         | 17 ++++++++--
 drivers/net/ethernet/broadcom/bcmsysport.h         |  1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c       | 21 +++++++-----
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  | 17 ++++++----
 drivers/net/ethernet/freescale/gianfar.c           | 14 ++++++--
 drivers/net/ethernet/freescale/ucc_geth.c          | 14 ++++++--
 drivers/of/of_mdio.c                               | 38 ----------------------
 include/linux/of_mdio.h                            | 10 ------
 13 files changed, 76 insertions(+), 109 deletions(-)

-- 
1.9.1
