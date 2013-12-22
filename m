From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 0/2] net/mlx4: Add support for TCP/IP offloads of vxlan tunneling
Date: Sun, 22 Dec 2013 17:26:10 +0200
Message-ID: <1387725972-10244-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, yanb@mellanox.com,
	ast@plumgrid.com, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60359 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753646Ab3LVP0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Dec 2013 10:26:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

These two patches add mlx4 support for TCP/IP offloads under vxlan tunneling.

V0 was submitted rebased against the other inflight mlx4 series we sent, 
but it turns out that there was another mlx4 patch in the air, its now merged 
as 6917441 "net: mlx4 calls skb_set_hash" which has tiny collision with V0 
as of content changes.


changes from V1:
 - applied feedback from Joe Perches: fixed an overly indented line, made a variable bool
   instead of int, initialize dev->hw_enc_features with |= to take into account
   setting done by the networking core during register_netdevice

changes from V0:
 - rebased against net-next commit 289dccb "net: use kfree_skb_list() helper",
   to avoid git am failure as of content change

Or.

Or Gerlitz (2):
  net/mlx4_core: Add basic support for TCP/IP offloads under tunneling
  net/mlx4_en: Add netdev support for TCP/IP offloads of vxlan
    tunneling

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |   94 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_resources.c |    6 ++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |   14 +++
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   14 +++-
 drivers/net/ethernet/mellanox/mlx4/fw.c           |   19 ++++-
 drivers/net/ethernet/mellanox/mlx4/main.c         |   14 +++
 drivers/net/ethernet/mellanox/mlx4/mcg.c          |   14 +++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |    3 +-
 drivers/net/ethernet/mellanox/mlx4/port.c         |   41 +++++++++
 include/linux/mlx4/cmd.h                          |    1 +
 include/linux/mlx4/cq.h                           |    5 +
 include/linux/mlx4/device.h                       |   37 ++++++++-
 include/linux/mlx4/qp.h                           |    6 ++
 13 files changed, 262 insertions(+), 6 deletions(-)
