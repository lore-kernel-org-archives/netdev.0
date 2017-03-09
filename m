From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v3 net-next 0/9] prepare mac operations for multiple queues
Date: Thu,  9 Mar 2017 11:03:08 +0000
Message-ID: <cover.1489055407.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:53023 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752121AbdCILDX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 06:03:23 -0500
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
g) CBS configuration

In this v3 patch-set version I included a new patch to enable CBS
configuration (Patch 9).

Joao Pinto (9):
  net: stmicro: multiple queues dt configuration
  net: stmicro: configure mtl rx and tx algorithms
  net: stmicro: configure tx queue weight
  net: stmicro: mtl rx queue enabled as dcb or avb
  net: stmicro: mapping mtl rx to dma channel
  net: stmicro: flow_ctrl functions adapted to mtl
  net: stmicro: prepare irq_status for mtl
  net: stmicro: mac debug prepared for multiple queues
  net: stmicro: configuration of CBS in case of a TX AVB queue

 Documentation/devicetree/bindings/net/stmmac.txt   |  58 +++++-
 drivers/net/ethernet/stmicro/stmmac/common.h       |  22 ++-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   6 +-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |   3 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       |  59 +++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 204 ++++++++++++++++++---
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   7 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 140 ++++++++++++--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 114 ++++++++++++
 include/linux/stmmac.h                             |  36 ++++
 10 files changed, 592 insertions(+), 57 deletions(-)

-- 
2.9.3
