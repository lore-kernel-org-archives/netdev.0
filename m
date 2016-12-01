From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 0/7]  net: ethernet: ti: cpsw: support placing CPDMA descriptors into DDR
Date: Thu, 1 Dec 2016 17:34:25 -0600
Message-ID: <20161201233432.6182-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series intended to add support for placing CPDMA descriptors into DDR by
introducing new DT property "descs_pool_size" to specify buffer descriptor's
pool size. The "descs_pool_size" defines total number of CPDMA
CPPI descriptors to be used for both ingress/egress packets
processing. If not specified - the default value 256 will be used
which will allow to place descriptor's pool into the internal CPPI
RAM.

This allows significantly to reduce UDP packets drop rate
for bandwidth >301 Mbits/sec (am57x).  

Before enabling this feature, the am437x SoC has to be fixed as it's proved
that it's not working when CPDMA descriptors placed in DDR.
So, the patch 1 fixes this issue.

Grygorii Strashko (7):
  net: ethernet: ti: cpdma: am437x: allow descs to be plased in ddr
  net: ethernet: ti: cpdma: fix desc re-queuing
  net: ethernet: ti: cpdma: minimize number of parameters in
    cpdma_desc_pool_create/destroy()
  net: ethernet: ti: cpdma: use devm_ioremap
  Documentation: DT: net: cpsw: allow to specify descriptors pool size
  net: ethernet: ti: cpsw: add support for descs_pool_size dt property
  Documentation: DT: net: cpsw: remove no_bd_ram property

 Documentation/devicetree/bindings/net/cpsw.txt |  8 ++-
 arch/arm/boot/dts/am33xx.dtsi                  |  1 -
 arch/arm/boot/dts/am4372.dtsi                  |  1 -
 arch/arm/boot/dts/dm814x.dtsi                  |  1 -
 arch/arm/boot/dts/dra7.dtsi                    |  1 -
 drivers/net/ethernet/ti/cpsw.c                 |  5 ++
 drivers/net/ethernet/ti/cpsw.h                 |  1 +
 drivers/net/ethernet/ti/davinci_cpdma.c        | 90 +++++++++++++++-----------
 drivers/net/ethernet/ti/davinci_cpdma.h        |  1 +
 9 files changed, 63 insertions(+), 46 deletions(-)

-- 
2.10.1
