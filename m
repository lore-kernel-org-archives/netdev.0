From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 0/7] net: ethernet: ti: cpsw: support placing CPDMA descriptors into DDR
Date: Fri, 6 Jan 2017 14:07:28 -0600
Message-ID: <20170106200735.4210-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx194.ext.ti.com ([198.47.27.80]:36923 "EHLO
        lelnx194.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937961AbdAFUHk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:07:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series intended to add support for placing CPDMA descriptors into DDR by
introducing new module parameter "descs_pool_size" to specify size of descriptor's
pool. The "descs_pool_size" defines total number of CPDMA
CPPI descriptors to be used for both ingress/egress packets
processing. If not specified - the default value 256 will be used
which will allow to place descriptor's pool into the internal CPPI
RAM.

In addition, added ability to re-split CPDMA pool of descriptors between RX and TX
path via ethtool '-G' command wich will allow to configure and fix number
of descriptors used by RX and TX path, which, then, will be split between
RX/TX channels proportionally depending on number of RX/TX channels and
its weight. 

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
  net: ethernet: ti: cpsw: add support for descs pool size configuration
  net: ethernet: ti: cpsw: add support for ringparam configuration
  Documentation: DT: net: cpsw: remove no_bd_ram property

 Documentation/devicetree/bindings/net/cpsw.txt |   3 -
 arch/arm/boot/dts/am33xx.dtsi                  |   1 -
 arch/arm/boot/dts/am4372.dtsi                  |   1 -
 arch/arm/boot/dts/dm814x.dtsi                  |   1 -
 arch/arm/boot/dts/dra7.dtsi                    |   1 -
 drivers/net/ethernet/ti/cpsw.c                 |  98 ++++++++++++++-
 drivers/net/ethernet/ti/davinci_cpdma.c        | 161 +++++++++++++++----------
 drivers/net/ethernet/ti/davinci_cpdma.h        |   5 +
 8 files changed, 199 insertions(+), 72 deletions(-)

-- 
2.10.1.dirty
