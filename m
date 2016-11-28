From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 00/16] net: fix fixed-link phydev leaks
Date: Mon, 28 Nov 2016 19:24:53 +0100
Message-ID: <1480357509-28074-1-git-send-email-johan@kernel.org>
Cc: Vince Bridgers <vbridger@opensource.altera.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Fugang Duan <fugang.duan@nxp.com>,
        Pantelis Antoniou <pantelis.antoniou@gmail.com>,
        Vitaly Bordug <vbordug@ru.mvista.com>,
        Claudiu Manoil <claudiu.manoil@freescale.com>,
        Li Yang <leoli@freescale.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Felix Fietkau <nbd@openwrt.org>,
        John Crispin <blogic@openwrt.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Lars Persson <lars.persson@axis.com>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series fixes failures to deregister and free fixed-link phydevs
that have been registered using the of_phy_register_fixed_link()
interface.

All but two drivers currently fail to do this and this series fixes most
of them with the exception of a staging driver and the stmmac drivers
which will be fixed by follow-on patches.

Included are also a couple of fixes for related of-node leaks.

Note that all patches except the of_mdio one have been compile-tested
only.

Also note that the series is against net due to dependencies not yet in
net-next.

Johan


Johan Hovold (16):
  net: dsa: slave: fix of-node leak and phy priority
  of_mdio: add helper to deregister fixed-link PHYs
  net: ethernet: altera: fix fixed-link phydev leaks
  net: ethernet: aurora: nb8800: fix fixed-link phydev leaks
  net: ethernet: bcmsysport: fix fixed-link phydev leaks
  net: ethernet: bcmgenet: fix fixed-link phydev leaks
  net: ethernet: fec: fix fixed-link phydev leaks
  net: ethernet: fs_enet: fix fixed-link phydev leaks
  net: ethernet: gianfar: fix fixed-link phydev leaks
  net: ethernet: ucc_geth: fix fixed-link phydev leaks
  net: ethernet: marvell: mvneta: fix fixed-link phydev leaks
  net: ethernet: mediatek: fix fixed-link phydev leaks
  net: ethernet: renesas: ravb: fix fixed-link phydev leaks
  net: ethernet: dwc_eth_qos: fix fixed-link phydev leaks
  net: ethernet: ti: davinci_emac: fix fixed-link phydev and of-node
    leaks
  net: dsa: slave: fix fixed-link phydev leaks

 drivers/net/ethernet/altera/altera_tse_main.c      |  9 ++++++++-
 drivers/net/ethernet/aurora/nb8800.c               |  9 +++++++--
 drivers/net/ethernet/broadcom/bcmsysport.c         | 17 +++++++++++-----
 drivers/net/ethernet/broadcom/genet/bcmmii.c       |  6 ++++++
 drivers/net/ethernet/freescale/fec_main.c          |  5 +++++
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |  7 ++++++-
 drivers/net/ethernet/freescale/gianfar.c           |  8 ++++++++
 drivers/net/ethernet/freescale/ucc_geth.c          | 23 +++++++++++++++-------
 drivers/net/ethernet/marvell/mvneta.c              |  5 +++++
 drivers/net/ethernet/mediatek/mtk_eth_soc.c        |  4 ++++
 drivers/net/ethernet/renesas/ravb_main.c           | 17 +++++++++++++---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c        | 20 ++++++++++++-------
 drivers/net/ethernet/ti/cpsw.c                     | 16 ++-------------
 drivers/net/ethernet/ti/davinci_emac.c             | 10 +++++++++-
 drivers/of/of_mdio.c                               | 15 ++++++++++++++
 include/linux/of_mdio.h                            |  4 ++++
 net/dsa/dsa.c                                      | 12 ++---------
 net/dsa/slave.c                                    | 19 +++++++++++++++---
 18 files changed, 152 insertions(+), 54 deletions(-)

-- 
2.7.3
