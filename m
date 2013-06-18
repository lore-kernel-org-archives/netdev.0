From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 0/2] Low latency Socket support
Date: Tue, 18 Jun 2013 16:18:26 +0300
Message-ID: <1371561508-11960-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:36210 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932160Ab3FRNSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 09:18:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Please pull those 2 patches, which add support in Low Latency Socket (LLS) to
mlx4_en.

Will send performance numbers later on

Thanks,
Amir

Changes from v0:
- Make sure we respect RCU grace period after calling napi_hash_del
- Disable GRO if LL polling is in process
- Allways enable LLS statistics when LLS is in use.
- Move code related to statistics that was mistakenly placed in patch 1/1 into
  patch 2/2
- MLX4_EN_CQ_STATEXXXX => MLX4_EN_CQ_STATE_XXXX
- Use bool instead of int

Amir Vadai (2):
  net/mlx4_en: Add Low Latency Socket (LLS) support
  net/mlx4_en: Low Latency recv statistics

 drivers/net/ethernet/mellanox/mlx4/en_cq.c      |   3 +
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  20 +++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  47 ++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |  15 ++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    | 127 ++++++++++++++++++++++++
 5 files changed, 207 insertions(+), 5 deletions(-)

-- 
1.8.3.251.g1462b67
