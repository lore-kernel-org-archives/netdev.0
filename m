From: Peter Chen <peter.chen@nxp.com>
Subject: [PATCH v2 00/15] add missing of_node_put after calling of_parse_phandle
Date: Mon, 1 Aug 2016 15:02:28 +0800
Message-ID: <1470034963-30506-1-git-send-email-peter.chen@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <vbridger@opensource.altera.com>,
	<isubramanian@apm.com>, <kchudgar@apm.com>,
	<yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
	<thomas.petazzoni@free-electrons.com>,
	<sergei.shtylyov@cogentembedded.com>, <peppe.cavallaro@st.com>,
	<alexandre.torgue@st.com>, <mugunthanvnm@ti.com>,
	<tremyfr@gmail.com>, <wxt@rock-chips.com>, <arnd@arndb.de>,
	<david.daney@cavium.com>, <huangdaode@hisilicon.com>,
	<jszhang@marvell.com>, Peter Chen <peter.chen@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0055.outbound.protection.outlook.com ([104.47.38.55]:36764
	"EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751989AbcHAHLd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 03:11:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch set fixes missing of_node_put issue at ethernet driver.
of_node_put needs to be called when the device node which is got
from of_parse_phandle has finished using.

The compilation test has passed by using allmodconfig for drivers/net/ethernet.

Thanks.

Changes for v2:
- If the device node is local variable, it can be put in the same function.
- If the device node will be used the whole driver life cycle,
  it should be put (call of_node_put) at driver's remove. 
  Patch [4, 5, 9, 14, 15/15]
- Fix the issue that the node still be used at error patch [6/15]
- Add acked for patch [11,12/15]

Peter Chen (15):
  ethernet: altera: add missing of_node_put
  ethernet: apm: xgene: add missing of_node_put after calling
    of_parse_phandle
  ethernet: arc: emac_main: add missing of_node_put after calling
    of_parse_phandle
  ethernet: aurora: nb8800: add missing of_node_put after calling
    of_parse_phandle
  ethernet: cavium: octeon: add missing of_node_put after calling
    of_parse_phandle
  ethernet: hisilicon: hns: hns_dsaf_mac: add missing of_node_put after
    calling of_parse_phandle
  ethernet: hisilicon: hns: hns_dsaf_main: add missing of_node_put after
    calling of_parse_phandle
  ethernet: marvell: mvneta: add missing of_node_put after calling
    of_parse_phandle
  ethernet: marvell: mvpp2: add missing of_node_put after calling
    of_parse_phandle
  ethernet: marvell: pxa168_eth: add missing of_node_put after calling
    of_parse_phandle
  ethernet: renesas: ravb_main: add missing of_node_put after calling
    of_parse_phandle
  ethernet: renesas: sh_eth: add missing of_node_put after calling
    of_parse_phandle
  ethernet: stmicro: stmmac: dwmac-socfpga: add missing of_node_put
    after calling of_parse_phandle
  ethernet: stmicro: stmmac: add missing of_node_put after calling
    of_parse_phandle
  ethernet: ti: davinci_emac: add missing of_node_put after calling
    of_parse_phandle

 drivers/net/ethernet/altera/altera_tse_main.c      |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     |  1 +
 drivers/net/ethernet/arc/emac_main.c               | 15 ++++++---
 drivers/net/ethernet/aurora/nb8800.c               |  2 ++
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c   |  3 ++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |  9 ++++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  7 +++--
 drivers/net/ethernet/marvell/mvneta.c              |  1 +
 drivers/net/ethernet/marvell/mvpp2.c               |  2 ++
 drivers/net/ethernet/marvell/pxa168_eth.c          |  1 +
 drivers/net/ethernet/renesas/ravb_main.c           |  1 +
 drivers/net/ethernet/renesas/sh_eth.c              |  1 +
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 36 ++++++++++++++++------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  1 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  7 +++--
 drivers/net/ethernet/ti/davinci_emac.c             |  1 +
 16 files changed, 67 insertions(+), 22 deletions(-)

-- 
1.9.1
