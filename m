From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Tue, 15 Jun 2010 12:00:52 +1000
Message-ID: <20100615120052.7202f20d.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

After merging the wireless tree, today's linux-next build (powerpc ppc64_defconfig)
failed like this:

drivers/net/ixgbe/ixgbe_ethtool.c: In function 'ixgbe_set_flags':
drivers/net/ixgbe/ixgbe_ethtool.c:2232: error: implicit declaration of function 'DPRINTK'
drivers/net/ixgbe/ixgbe_ethtool.c:2232: error: 'PROBE' undeclared (first use in this function)
drivers/net/ixgbe/ixgbe_ethtool.c:2232: error: 'INFO' undeclared (first use in this function)

Commit 28c8e4790ca5ef75f54895ca46437f9fbb433ddf ("ixgbe: fix automatic
LRO/RSC settings for low latency") from the net-current tree added
another use of DPRINTK which needs comverting to e_info().  I applied the
following patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 15 Jun 2010 11:43:33 +1000
Subject: [PATCH] net: ixgbe_ethtool merge fix up

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 65fe1f5..093461b 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2229,7 +2229,7 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 		} else if (!adapter->rx_itr_setting) {
 			netdev->features &= ~ETH_FLAG_LRO;
 			if (data & ETH_FLAG_LRO)
-				DPRINTK(PROBE, INFO, "rx-usecs set to 0, "
+				e_info("rx-usecs set to 0, "
 					"LRO/RSC cannot be enabled.\n");
 		}
 	}
-- 
1.7.1

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
