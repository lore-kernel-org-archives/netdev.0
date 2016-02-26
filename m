From: John Crispin <blogic@openwrt.org>
Subject: [PATCH V2 00/12] net-next: mediatek: add ethernet driver
Date: Fri, 26 Feb 2016 15:21:32 +0100
Message-ID: <1456496504-50429-1-git-send-email-blogic@openwrt.org>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
	Matthias Brugger <matthias.bgg@gmail.com>,
	=?UTF-8?q?Steven=20Liu=20=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
	<steven.liu@mediatek.com>,
	=?UTF-8?q?Carlos=20Huang=20=28=E9=BB=83=E5=A3=AB=E5=BD=B0=29?=
	<Carlos.Huang@mediatek.com>,
	=?UTF-8?q?Fred=20Chang=20=28=E5=BC=B5=E5=98=89=E5=AE=8F=29?=
	<Fred.Chang@mediatek.com>, John Crispin <blogic@openwrt.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series adds support for the Ralink/Mediatek ethernet core. The driver
works on all SoCs made by Ralink and all SoCs made by MTK/WCN that were
produced after the acquisition.

There have been a lot of changes since I posted this start of january. The
most important ones are listed below

Changes in V2
* change the namespace of the functions from fe_* to mtk_*
* add support for the latest generation of ARM SoCs
* add dual MAC support
* remove the swconfig specific bits
* remove most of the magic values and replace them with defines
* add verbose descriptions to the patches

John Crispin (12):
  net-next: mediatek: Document ralink/mediatek SoC ethernet binding
  net-next: mediatek: add the drivers core files
  net-next: mediatek: add embedded switch driver (ESW)
  net-next: mediatek: add gigabit switch driver (GSW)
  net-next: mediatek: add support for rt2880
  net-next: mediatek: add support for rt3050
  net-next: mediatek: add support for rt3883
  net-next: mediatek: add support for mt7620
  net-next: mediatek: add support for mt7621
  net-next: mediatek: add support for mt7623
  net-next: mediatek: add Kconfig and Makefile
  net-next: mediatek: add an entry to MAINTAINERS

 .../devicetree/bindings/net/mediatek-net-esw.txt   |   25 +
 .../devicetree/bindings/net/mediatek-net-gsw.txt   |   48 +
 .../devicetree/bindings/net/mediatek-net.txt       |  113 +
 MAINTAINERS                                        |    7 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/mediatek/Kconfig              |   70 +
 drivers/net/ethernet/mediatek/Makefile             |   23 +
 drivers/net/ethernet/mediatek/esw_rt3050.c         |  642 ++++++
 drivers/net/ethernet/mediatek/esw_rt3050.h         |   21 +
 drivers/net/ethernet/mediatek/ethtool.c            |  223 ++
 drivers/net/ethernet/mediatek/ethtool.h            |   22 +
 drivers/net/ethernet/mediatek/gsw_mt7620.c         |  256 +++
 drivers/net/ethernet/mediatek/gsw_mt7620.h         |  277 +++
 drivers/net/ethernet/mediatek/gsw_mt7621.c         |  265 +++
 drivers/net/ethernet/mediatek/gsw_mt7623.c         |  417 ++++
 drivers/net/ethernet/mediatek/mdio.c               |  265 +++
 drivers/net/ethernet/mediatek/mdio.h               |   27 +
 drivers/net/ethernet/mediatek/mdio_mt7620.c        |  168 ++
 drivers/net/ethernet/mediatek/mdio_rt2880.c        |  224 ++
 drivers/net/ethernet/mediatek/mdio_rt2880.h        |   24 +
 drivers/net/ethernet/mediatek/mtk_eth_soc.c        | 2170 ++++++++++++++++++++
 drivers/net/ethernet/mediatek/mtk_eth_soc.h        |  720 +++++++
 drivers/net/ethernet/mediatek/soc_mt7620.c         |  296 +++
 drivers/net/ethernet/mediatek/soc_mt7621.c         |  148 ++
 drivers/net/ethernet/mediatek/soc_mt7623.c         |  169 ++
 drivers/net/ethernet/mediatek/soc_rt2880.c         |   71 +
 drivers/net/ethernet/mediatek/soc_rt3050.c         |  138 ++
 drivers/net/ethernet/mediatek/soc_rt3883.c         |   72 +
 29 files changed, 6903 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/mediatek-net-esw.txt
 create mode 100644 Documentation/devicetree/bindings/net/mediatek-net-gsw.txt
 create mode 100644 Documentation/devicetree/bindings/net/mediatek-net.txt
 create mode 100644 drivers/net/ethernet/mediatek/Kconfig
 create mode 100644 drivers/net/ethernet/mediatek/Makefile
 create mode 100644 drivers/net/ethernet/mediatek/esw_rt3050.c
 create mode 100644 drivers/net/ethernet/mediatek/esw_rt3050.h
 create mode 100644 drivers/net/ethernet/mediatek/ethtool.c
 create mode 100644 drivers/net/ethernet/mediatek/ethtool.h
 create mode 100644 drivers/net/ethernet/mediatek/gsw_mt7620.c
 create mode 100644 drivers/net/ethernet/mediatek/gsw_mt7620.h
 create mode 100644 drivers/net/ethernet/mediatek/gsw_mt7621.c
 create mode 100644 drivers/net/ethernet/mediatek/gsw_mt7623.c
 create mode 100644 drivers/net/ethernet/mediatek/mdio.c
 create mode 100644 drivers/net/ethernet/mediatek/mdio.h
 create mode 100644 drivers/net/ethernet/mediatek/mdio_mt7620.c
 create mode 100644 drivers/net/ethernet/mediatek/mdio_rt2880.c
 create mode 100644 drivers/net/ethernet/mediatek/mdio_rt2880.h
 create mode 100644 drivers/net/ethernet/mediatek/mtk_eth_soc.c
 create mode 100644 drivers/net/ethernet/mediatek/mtk_eth_soc.h
 create mode 100644 drivers/net/ethernet/mediatek/soc_mt7620.c
 create mode 100644 drivers/net/ethernet/mediatek/soc_mt7621.c
 create mode 100644 drivers/net/ethernet/mediatek/soc_mt7623.c
 create mode 100644 drivers/net/ethernet/mediatek/soc_rt2880.c
 create mode 100644 drivers/net/ethernet/mediatek/soc_rt3050.c
 create mode 100644 drivers/net/ethernet/mediatek/soc_rt3883.c

-- 
1.7.10.4
