From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/9] net/mlx4_en: Add support for unicast MAC filtering and FDB operations
Date: Tue,  5 Feb 2013 13:28:27 +0200
Message-ID: <1360063716-13415-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yan Burman <yanb@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:33920 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751383Ab3BEL3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 06:29:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series from Yan Burman adds support for unicast MAC address filtering and
ndo FDB operations.  It also includes some optimizations to loopback related
decisions and checks in the TX/RX fast path and one cleanup, all in separate
patches.

Today, when adding macvlan devices, the NIC goes into promiscuous mode, since
unicast MAC filtering is not supported. With these changes, macvlan devices can
be added without the penalty of promiscuous mode. Also, now it is possible to
have bridge under multi-function configuration that include PF and VFs.  In
order to use bridge over PF/VFs, VM MAC fdb entries must be added e.g. using
'bridge fdb add' command.

Yan Burman (9):
  net/mlx4_en: Optimize loopback related checks in data path
  net/mlx4_en: Optimize Rx fast path filter checks
  net/mlx4_en: Cleanup multiline strings
  net/mlx4: Move Ethernet related functionality from mlx4_core to
    mlx4_en
  net/mlx4_en: Re-arrange ndo_set_rx_mode related code
  net/mlx4_en: Save previous MAC address of the port so we can replace
    it later
  net/mlx4_en: Manage hash of MAC addresses per port
  net/mlx4_en: Add unicast MAC filtering
  net/mlx4_en: Implement ndo fdb functionality

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c  |    9 +-
 drivers/net/ethernet/mellanox/mlx4/en_main.c     |   22 +
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |  743 +++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/en_rx.c       |   53 +-
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c |    3 +
 drivers/net/ethernet/mellanox/mlx4/en_tx.c       |    2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c        |    5 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h        |    7 -
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h     |   31 +-
 drivers/net/ethernet/mellanox/mlx4/port.c        |  193 +------
 include/linux/mlx4/device.h                      |    5 +-
 11 files changed, 685 insertions(+), 388 deletions(-)

-- 
1.7.6.4
