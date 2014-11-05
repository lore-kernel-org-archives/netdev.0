From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/2] ethtool, net/mlx4_en: RSS hash function selection
Date: Wed,  5 Nov 2014 13:59:27 +0200
Message-ID: <1415188769-19593-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50346 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754507AbaKEL7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 06:59:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset by Eyal adds support in set/get of RSS hash function. Current
supported functions are Toeplitz and XOR. The API is design to enable adding
new hash functions without breaking backward compatibility.
If a driver want to use this API need to implement [gs]et_rxfh_func() callbacks
in ethtool_ops.
Userspace patch will be sent after API is available in kernel.

The patchset was applied and tested over commit 30349bd ("net: phy: spi_ks8995:
remove sysfs bin file by registered attribute")

Amir

Eyal Perry (2):
  ethtool: Support for configurable RSS hash function
  net/mlx4_en: Support for configurable RSS hash function

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 40 +++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  9 +++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      | 11 ++++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  3 +-
 include/linux/ethtool.h                         | 28 +++++++++++++
 include/uapi/linux/ethtool.h                    |  6 ++-
 net/core/ethtool.c                              | 52 +++++++++++++++++--------
 7 files changed, 127 insertions(+), 22 deletions(-)

-- 
1.8.3.4
