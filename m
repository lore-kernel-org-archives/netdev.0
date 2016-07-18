From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 0/2] Safe flow for mlx4_en configuration change
Date: Mon, 18 Jul 2016 18:35:10 +0300
Message-ID: <1468856112-17858-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44226 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751537AbcGRPge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 11:36:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset improves the mlx4_en driver resiliency, especially on
systems with low memory.  Upon a configuration change that requires
the allocation of new resources, we first try to allocate, prior to
destroying the current ones.  Once it is successfully done,
we release the old resources and attach the new ones.  Otherwise, we
stay with a functioning interface having the same old configuration.

This improvement became of greater significance after removing the use
of vmap.

Eugenia Emantayev (2):
  net/mlx4_en: Move filters cleanup to a proper location
  net/mlx4_en: Add resilience in low memory systems

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  54 +++++++-----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 110 +++++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |   3 -
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |   9 +-
 4 files changed, 136 insertions(+), 40 deletions(-)

-- 
1.8.3.1
