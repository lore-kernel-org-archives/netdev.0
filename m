From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V3 0/2] net/mlx4: Add support for TCP/IP offloads of vxlan tunneling
Date: Mon, 23 Dec 2013 16:09:42 +0200
Message-ID: <1387807784-22056-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, yanb@mellanox.com,
	ast@plumgrid.com, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:42877 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757404Ab3LWOJx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Dec 2013 09:09:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

These two patches add mlx4 support for TCP/IP offloads under vxlan tunneling.

changes from V2:
 - applied feedback from Dave to avoid lisp stype double brackets

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
