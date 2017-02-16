From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH net-next v2 0/3] add support for multiple queues/channels in stmmac
Date: Thu, 16 Feb 2017 11:19:38 +0000
Message-ID: <cover.1487243644.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.60.111]:51283 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753530AbdBPLTq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 06:19:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch-set was built in order to be easy for a developer to have
a clear view of what was done to add multiple queues/channels to stmmac.
It shows a progressive work starting in an initial mac functions upgrade,
followed by dma related functions upgrade and finally introcuding the
multiple buffers.

Some of the functions had to be broken in RX and TX related, in order to
enable separated treatment, since the number of RX queues can be different
from the number of TX queues for example.

Each patch and the final patch-set were tested using a 4.21 EQOS IP Core.

Joao Pinto (3):
  net: stmicro: prepare dwmac4 core for mtl
  net: stmicro: prepare dwmac4 dma for mtl
  net: stmicro: multiple buffer support

 Documentation/devicetree/bindings/net/stmmac.txt   |   11 +
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |   44 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   89 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |    6 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |   16 +-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    3 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |   19 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       |   49 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  |  194 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c   |  297 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h   |   25 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c   |   58 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |   15 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |   14 +-
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |   47 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   47 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   25 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 1961 ++++++++++++++------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   33 +
 include/linux/stmmac.h                             |    8 +
 20 files changed, 2152 insertions(+), 809 deletions(-)

-- 
2.9.3
