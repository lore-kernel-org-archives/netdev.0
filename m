From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH 0/2 v4] net/macb: RX path enhancement
Date: Wed, 5 Jun 2013 09:57:10 +0200
Message-ID: <cover.1370418770.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	<hein_tibosch@yahoo.es>, <s.trumtrar@pengutronix.de>,
	<michal.simek@xilinx.com>, <monstr@monstr.eu>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is the patch series for modifying the RX path in macb driver.
This change applies on GEM variant of the Cadence IP and introduces
function pointers to match the path to the proper adapter. The move
to RX buffers adapted to MTU and that can be DMAed directly in SKB
is done in two steps but can be merged in a single patch.

v4: - rebased on top of net-next
    - removed the last patch of the series which needs rework

v3: - rebased on top of net-next (containing recently added
      net/macb: fix ISR clear-on-write behavior only for some SoC)
    - added the ___cacheline_aligned_in_smp qualifier to napi field
      following Ben Hutchings' advice

v2: - gave up the idea of using non-coherent memory for
      rx buffers
    - addition of the struct macb layout optimization


Nicolas Ferre (2):
  net/macb: increase RX buffer size for GEM
  net/macb: change RX path for GEM

 drivers/net/ethernet/cadence/macb.c | 323 +++++++++++++++++++++++++++++++-----
 drivers/net/ethernet/cadence/macb.h |  14 ++
 2 files changed, 295 insertions(+), 42 deletions(-)

-- 
1.8.2.2
