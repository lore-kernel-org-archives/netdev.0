From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 0/3] Optimisation of fs_enet ethernet driver
Date: Wed, 24 Aug 2016 12:36:38 +0200 (CEST)
Message-ID: <cover.1472033140.git.christophe.leroy@c-s.fr>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org
To: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
 Vitaly Bordug <vbordug@ru.mvista.com>, davem@davemloft.net
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

This set optimises the freescale fs_enet ethernet driver:
1/ Merge of RX and TX NAPI functions in order to limit the amount of
interrupts
2/ Do not unmap DMA when packets len is below copybreak, otherwise there
is no benefit in copying the skb instead of allocating a new one
3/ Make copybreak value configurable as the optimised value is not the
same on all targets

chleroy (3):
  net: fs_enet: merge NAPI RX and NAPI TX
  net: fs_enet: don't unmap DMA when packet len is below copybreak
  net: fs_enet: make rx_copybreak value configurable

 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  | 303 +++++++++------------
 drivers/net/ethernet/freescale/fs_enet/fs_enet.h   |  16 +-
 drivers/net/ethernet/freescale/fs_enet/mac-fcc.c   |  57 +---
 drivers/net/ethernet/freescale/fs_enet/mac-fec.c   |  57 +---
 drivers/net/ethernet/freescale/fs_enet/mac-scc.c   |  57 +---
 include/linux/fs_enet_pd.h                         |   1 -
 6 files changed, 178 insertions(+), 313 deletions(-)

-- 
2.1.0
