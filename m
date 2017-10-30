From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 0/6] net: ppv2: various improvements
Date: Mon, 30 Oct 2017 11:23:27 +0100
Message-ID: <20171030102333.30781-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This series includes various patches improving the Marvell PPv2 driver.
I send them as a series to avoid any possible merge conflict.

- Patches 1 and 2 improve the initializing of the Tx and Rx FIFO.
- Patch 3 initialize the RSS table to evenly distribute the ingress
  packets across multiple Rx queues based on their hashes.
- Patch 4 limits the number of TSO segments sent to the driver, to avoid
  having more segments to handle than the corresponding number of
  available descriptors.
- Patch 5 and 6 are cosmetic improvements.

This applies on today's net-next branch, The patches were tested
extensively (I ran iperf and http downloads in parallel, transferring
TBs of data).

Thanks!
Antoine

Antoine Tenart (6):
  net: mvpp2: set the Rx FIFO size depending on the port speeds for
    PPv2.2
  net: mvpp2: initialize the Tx FIFO size
  net: mvpp2: initialize the RSS tables
  net: mvpp2: limit TSO segments and use stop/wake thresholds
  net: mvpp2: use the aggr txq size define everywhere
  net: mvpp2: simplify the Tx desc set DMA logic

 drivers/net/ethernet/marvell/mvpp2.c | 186 +++++++++++++++++++++++++++--------
 1 file changed, 147 insertions(+), 39 deletions(-)

-- 
2.14.3
