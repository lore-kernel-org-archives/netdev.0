From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 1 Dec 2016 12:36:12 +1100
Message-ID: <20161201123612.43c88444@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Cyrille Pitchen <cyrille.pitchen@atmel.com>,
        Zach Brown <zach.brown@ni.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/cadence/macb.c

between commit:

  a0b44eea372b ("net: macb: fix the RX queue reset in macb_rx()")

from the net tree and commit:

  b410d13e10db ("net: macb: Use variables with defaults for tx/rx ring sizes instead of hardcoded values")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/cadence/macb.c
index ec09fcece711,0e489bb82456..000000000000
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@@ -974,8 -990,7 +990,8 @@@ static inline void macb_init_rx_ring(st
  		bp->rx_ring[i].ctrl = 0;
  		addr += bp->rx_buffer_size;
  	}
- 	bp->rx_ring[RX_RING_SIZE - 1].addr |= MACB_BIT(RX_WRAP);
+ 	bp->rx_ring[bp->rx_ring_size - 1].addr |= MACB_BIT(RX_WRAP);
 +	bp->rx_tail = 0;
  }
  
  static int macb_rx(struct macb *bp, int budget)
@@@ -1617,7 -1735,9 +1737,7 @@@ static void macb_init_rings(struct mac
  	}
  	bp->queues[0].tx_head = 0;
  	bp->queues[0].tx_tail = 0;
- 	bp->queues[0].tx_ring[TX_RING_SIZE - 1].ctrl |= MACB_BIT(TX_WRAP);
+ 	bp->queues[0].tx_ring[bp->tx_ring_size - 1].ctrl |= MACB_BIT(TX_WRAP);
 -
 -	bp->rx_tail = 0;
  }
  
  static void macb_reset_hw(struct macb *bp)
