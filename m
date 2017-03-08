From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH net-next 0/8] prepare mac operations for multiple queues
Date: Wed,  8 Mar 2017 11:03:07 +0000
Message-ID: <cover.1488969672.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:60135 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752780AbdCHL5c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 06:57:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As agreed with David Miller, this patch-set is the first of 3 to enable
multiple queues in stmmac.

This first one concentrates on mac operations adding functionalities as:
a) Configuration through DT
b) RX and TX scheduling algorithms programming
b) TX queues weight programming (essential in weightes algorithms)
c) RX enable as DCB or AVB (preparing for future AVB support)
d) Mapping RX queue to DMA channel
e) IRQ treatment prepared for multiple queues
f) Debug dump prepared for multiple queues

Joao Pinto (8):
  net: stmicro: multiple queues dt configuration
  net: stmicro: configure mtl rx and tx algorithms
  net: stmicro: configure tx queue weight
  net: stmicro: mtl rx queue enabled as dcb or avb
  net: stmicro: mapping mtl rx to dma channel
  net: stmicro: flow_ctrl functions adapted to mtl
  net: stmicro: prepare irq_status for mtl
  net: stmicro: mac debug prepared for multiple queues

 Documentation/devicetree/bindings/net/stmmac.txt   |  40 +++++
 drivers/net/ethernet/stmicro/stmmac/common.h       |  18 ++-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   6 +-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |   3 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       |  26 +++-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 162 +++++++++++++++++----
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   7 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 111 +++++++++++---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  91 ++++++++++++
 include/linux/stmmac.h                             |  30 ++++
 10 files changed, 438 insertions(+), 56 deletions(-)

-- 
2.9.3
