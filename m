From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 00/11] Mellanox NIC drivers update, June 23 2015
Date: Tue, 23 Jun 2015 17:14:11 +0300
Message-ID: <1435068862-26488-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41162 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933608AbbFWOOs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2015 10:14:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series has two fixes from Eran to his recent SRIOV counters work in 
mlx4 and few more updates from Saeed and Achiad to the mlx5 Ethernet
code. All fixes here relate to net-next code, so no need for -stable.

Or.


Changes from V0:
 - dropped the patch that move us to poll RX completions 1st, based
   on feedback from Dave.

Achiad Shochat (7):
  net/mlx5e: Poll rx cq before tx cq to improve round-trip latency
  net/mlx5e: Remove re-assignment of wq type in mlx5e_enable_rq()
  net/mlx5e: Avoid redundant dev_kfree_skb() upon NOP completion
  net/mlx5e: Avoid TX CQE generation if more xmit packets expected
  net/mlx5e: Remove extra spaces
  net/mlx5e: Remove mlx5e_cq.sqrq back-pointer
  net/mlx5e: Pop cq outside mlx5e_get_cqe

Eran Ben Elisha (2):
  net/mlx4_en: Fix off-by-four in ethtool
  net/mlx4_en: Use HW counters for rx/tx bytes/packets in PF device

Saeed Mahameed (3):
  net/mlx5e: Static mapping of netdev priv resources to/from netdev TX queues
  net/mlx5e: Use skb_shinfo(skb)->gso_segs rather than counting them
  net/mlx5e: Prefetch skb data on RX

 drivers/net/ethernet/mellanox/mlx4/en_port.c      | 14 ++++
 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h   |  5 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  6 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 45 ++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |  5 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 92 +++++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 10 +--
 7 files changed, 96 insertions(+), 81 deletions(-)

-- 
2.3.7


Achiad Shochat (6):
  net/mlx5e: Remove re-assignment of wq type in mlx5e_enable_rq()
  net/mlx5e: Avoid redundant dev_kfree_skb() upon NOP completion
  net/mlx5e: Avoid TX CQE generation if more xmit packets expected
  net/mlx5e: Remove extra spaces
  net/mlx5e: Remove mlx5e_cq.sqrq back-pointer
  net/mlx5e: Pop cq outside mlx5e_get_cqe

Eran Ben Elisha (2):
  net/mlx4_en: Fix off-by-four in ethtool
  net/mlx4_en: Use HW counters for rx/tx bytes/packets in PF device

Saeed Mahameed (3):
  net/mlx5e: Static mapping of netdev priv resources to/from netdev TX
    queues
  net/mlx5e: Use skb_shinfo(skb)->gso_segs rather than counting them
  net/mlx5e: Prefetch skb data on RX

 drivers/net/ethernet/mellanox/mlx4/en_port.c      | 14 ++++
 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h   |  5 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  6 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 45 ++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |  5 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 92 +++++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |  4 +-
 7 files changed, 93 insertions(+), 78 deletions(-)

-- 
2.3.7
