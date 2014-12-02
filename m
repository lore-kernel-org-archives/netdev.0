From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 0/2] ethtool, net/mlx4_en: RSS hash function selection
Date: Tue,  2 Dec 2014 16:20:47 +0200
Message-ID: <1417530049-6943-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:58345 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753860AbaLBOVB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2014 09:21:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset by Eyal adds support in set/get of RSS hash function. Current
supported functions are Toeplitz and XOR. The API is design to enable adding
new hash functions without breaking backward compatibility.
Userspace patch will be sent after API is available in kernel.


The patchset was applied and tested over commit cd4c910 ("netpoll: delete
defconfig references to obsolete NETPOLL_TRAP")

Amir

Changes from V1:
- Patch 1/2 - ethtool: Support for configurable RSS hash function:
   - Accept an hfunc the chip is using instead of only ETH_RSS_HASH_NO_CHANGE.
   - Provide an accurate hfunc value in get_rxfh() call.
   - Changed the behavior of the get_rxfh() w.r.t the validation of the
     arguments. Function will return 0 instead of -EOPNOSUPP when all arguments
     are NULL.

Changes from V0:
- Patch 1/2 - ethtool: Support for configurable RSS hash function:
 - Add ETH prefix to RSS_HASH_* definitions
 - Moved the strings array to ethtool.c
 - Extend {get,set}_rxfh with additional arg instead of adding new
   ethtool_option and adopt the change into drivers implementations.
 - Moved indir_size and key_size validation into drivers implantation
 - Documented hfunc filed in ethtool_rxfh struct
- Patch 2/2 - net/mlx4_en: Support for configurable RSS hash function
 - Remove redundant priv->rss_hash_fn_caps 
 - Use == operator instead & when determining requested hash function. 

Eyal Perry (2):
  ethtool: Support for configurable RSS hash function
  net/mlx4_en: Support for configurable RSS hash function

 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c       | 11 +++-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    | 20 ++++++-
 drivers/net/ethernet/broadcom/tg3.c                | 20 ++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 18 +++++-
 drivers/net/ethernet/emulex/benet/be_ethtool.c     | 12 +++-
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c   | 12 +++-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 17 +++++-
 drivers/net/ethernet/intel/igb/igb_ethtool.c       | 16 ++++-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    | 37 +++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     | 11 ++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         | 14 ++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |  2 +-
 drivers/net/ethernet/sfc/ethtool.c                 | 18 ++++--
 drivers/net/vmxnet3/vmxnet3_ethtool.c              | 15 ++++-
 include/linux/ethtool.h                            | 42 +++++++++----
 include/uapi/linux/ethtool.h                       | 10 +++-
 net/core/ethtool.c                                 | 69 ++++++++++++----------
 17 files changed, 272 insertions(+), 72 deletions(-)

-- 
1.8.3.4
