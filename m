From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Tue, 15 Jun 2010 12:00:41 +1000
Message-ID: <20100615120041.27b02c6f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/ixgbe/ixgbe_ethtool.c between commit
28c8e4790ca5ef75f54895ca46437f9fbb433ddf ("ixgbe: fix automatic LRO/RSC
settings for low latency") from the net-current tree and commit
849c45423c0c108e08d67644728cc9b0ed225fa1 ("ixgbe: Use netdev_<level>,
dev_<level>, pr_<level>") from the net tree.

I fixed it up (see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ixgbe/ixgbe_ethtool.c
index 3a93a81,644e3d2..0000000
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@@ -2132,11 -2155,9 +2130,10 @@@ static int ixgbe_set_coalesce(struct ne
  		 */
  		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
  			adapter->flags2 &= ~IXGBE_FLAG2_RSC_ENABLED;
 -			netdev->features &= ~NETIF_F_LRO;
 -			e_info("rx-usecs set to 0, disabling RSC\n");
 -
 +			if (netdev->features & NETIF_F_LRO) {
 +				netdev->features &= ~NETIF_F_LRO;
- 				DPRINTK(PROBE, INFO, "rx-usecs set to 0, "
- 					"disabling LRO/RSC\n");
++				e_info("rx-usecs set to 0, disabling LRO/RSC\n");
 +			}
  			need_reset = true;
  		}
  	}
