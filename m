From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/2] net, igb, mlx4: Copy exact header to SKB linear buffer
Date: Thu,  8 May 2014 15:50:32 +0300
Message-ID: <1399553434-25617-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:54121 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754530AbaEHMvF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2014 08:51:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset consist of 2 patches written by Ido:
First patch is making the header length computation function from igb and igbe
generlized at net/core/utils.c.
Second patch is using this helper function to copy the exact packet header to
the linear buffer instead of constant length.

Patches were applied on top of commit 79e0f1c: "ipv6: Need to sock_put on csum
error"

Thanks,
Amir

Ido Shamay (2):
  net: Expose header length compution function
  net/mlx4_en: Copy exact header to SKB linear part

 drivers/net/ethernet/intel/igb/igb_main.c     | 109 +-----------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 116 +-------------------------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c    |  12 +--
 include/linux/net.h                           |   2 +
 net/core/utils.c                              | 104 +++++++++++++++++++++++
 5 files changed, 115 insertions(+), 228 deletions(-)

-- 
1.8.3.4
