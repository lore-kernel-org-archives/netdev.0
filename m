From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v2 0/3] Optimisation of fs_enet ethernet driver
Date: Fri,  9 Sep 2016 14:26:18 +0200 (CEST)
Message-ID: <cover.1473422536.git.christophe.leroy@c-s.fr>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org
To: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
        Vitaly Bordug <vbordug@ru.mvista.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set optimises the freescale fs_enet ethernet driver:
1/ Merge of RX and TX NAPI functions in order to limit the amount of
interrupts
2/ Do not unmap DMA when packets len is below copybreak, otherwise there
is no benefit in copying the skb instead of allocating a new one
3/ Make copybreak value configurable as the optimised value is not the
same on all targets

Christophe Leroy (3):
  net: fs_enet: merge NAPI RX and NAPI TX
  net: fs_enet: don't unmap DMA when packet len is below copybreak
  net: fs_enet: make rx_copybreak value configurable

 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  | 344 +++++++++++----------
 drivers/net/ethernet/freescale/fs_enet/fs_enet.h   |  16 +-
 drivers/net/ethernet/freescale/fs_enet/mac-fcc.c   |  57 +---
 drivers/net/ethernet/freescale/fs_enet/mac-fec.c   |  57 +---
 drivers/net/ethernet/freescale/fs_enet/mac-scc.c   |  57 +---
 5 files changed, 220 insertions(+), 311 deletions(-)

-- 
2.1.0
