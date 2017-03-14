From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v2 net-next 00/11] net: stmmac: prepare dma operations for multiple queues
Date: Tue, 14 Mar 2017 10:24:22 +0000
Message-ID: <cover.1489485739.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:45430 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750891AbdCNKYj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 06:24:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As agreed with David Miller, this patch-set is the second of 3 to enable
multiple queues in stmmac.

This second one concentrates on dma operations adding functionalities as:
a) DMA Operation Mode configuration per channel and done in the multiple
queues configuration function
b) DMA IRQ enable and Disable by channel
c) DMA start and stop by channel
d) RX and TX ring length configuration by channel
e) RX and TX set tail pointer by channel
f) DMA Channel initialization broke into Channel comon, RX and TX
initialization
g) TSO being configured for all available channels
h) DMA interrupt treatment by channel

Joao Pinto (11):
  net: stmmac: prepare dma op mode config for multiple queues
  net: stmmac: enable/disable dma irq prepared for multiple queues
  net: stmmac: rx/tx dma start/stop prepared for multiple queues
  net: stmmac: prepare stmmac_tx_err for multiple queues
  net: stmmac: prepare dma interrupt treatment for multiple queues
  net: stmmac: rx watchdog config prepared for multiple queues
  net: stmmac: rx and tx ring length prepared for multiple queues
  net: stmmac: prepare rx/tx set tail function for multiple queues
  net: stmmac: dma channel init prepared for multiple queues
  net: stmmac: tso init prepared for multiple queues
  net: stmmac: stmmac interrupt treatment prepared for multiple queues

 drivers/net/ethernet/stmicro/stmmac/common.h       |  31 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |   3 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c   | 192 ++++++-----
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h   |  20 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c   |  56 ++--
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |  15 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |  14 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   3 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 373 ++++++++++++++++-----
 9 files changed, 468 insertions(+), 239 deletions(-)

-- 
2.9.3
