From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/6] Mellanox driver update Jul-08-2014
Date: Tue,  8 Jul 2014 11:25:18 +0300
Message-ID: <1404807924-29038-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:44678 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753532AbaGHI01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2014 04:26:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch set introduce some small bug fixes.
Most of the patches are small fixes to cornet case bugs.
The patch by Noa ("Fix mac_hash database inconsistency") was sent in the past
[1] and was droped because a fix to the bonding code was supposed to make it
unnecessary. After a second look on the patch, it is still needed even
after the direct access to dev_addr by the bonding will be fixed.

Patches were applied and tested over commit bd4578b
("drivers/net/hyperv/netvsc.c: remove unnecessary null test before kfree")

[1] - http://permalink.gmane.org/gmane.linux.network/315900

Thanks,
Amir

Eugenia Emantayev (4):
  net/mlx4_en: Fix set port ratelimit
  net/mlx4_en: Run loopback test only when port is up
  net/mlx4: Verify port number in __mlx4_unregister_mac
  net/mlx4_en: Do not disable vlan filter during promiscuous mode

Noa Osherovich (1):
  net/mlx4_en: Fix mac_hash database inconsistency

Yishai Hadas (1):
  net/mlx4_en: Do not count LLC/SNAP in MTU calculation

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   | 33 ++++++++++--------------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c       |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c |  3 ++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h        |  5 ----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h     |  4 +--
 drivers/net/ethernet/mellanox/mlx4/port.c        | 32 ++++++++++++++++++-----
 include/linux/mlx4/device.h                      | 11 ++++++++
 7 files changed, 54 insertions(+), 36 deletions(-)

-- 
1.8.3.4
