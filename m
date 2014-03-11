From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH next-next 0/11] Using dev_kfree_skb_any for functions called in multiple contexts
Date: Mon, 10 Mar 2014 20:16:40 -0700
Message-ID: <871ty9qvaf.fsf_-_@xmission.com>
References: <874n3fow2i.fsf@xmission.com>
	<20140304.160825.893718566461536483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:41928 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643AbaCKDQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 23:16:46 -0400
In-Reply-To: <20140304.160825.893718566461536483.davem@davemloft.net> (David
	Miller's message of "Tue, 04 Mar 2014 16:08:25 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patchset should be an uncontroversial set of changes to change
dev_kfree_skb to dev_kfree_skb_any for code paths that are called in
hard irq contexts in addition to other contexts.  netpoll is the reason
this code gets called in multiple contexts.

There is more coming but these changes are a good starting place, and
stand on their own.

Eric W. Biederman (11):
      bonding: Call dev_kfree_skby_any instead of kfree_skb.
      bnx2: Call dev_kfree_skby_any instead of dev_kfree_skb.
      bnx2x: Call dev_kfree_skby_any instead of dev_kfree_skb.
      tg3: Call dev_kfree_skby_any instead of dev_kfree_skb.
      bcm63xx_enet: Call dev_kfree_skby_any instead of dev_kfree_skb.
      e1000: Call dev_kfree_skby_any instead of dev_kfree_skb.
      igbvf: Call dev_kfree_skby_any instead of dev_kfree_skb.
      ixgb: Call dev_kfree_skby_any instead of dev_kfree_skb.
      mlx4: Call dev_kfree_skby_any instead of dev_kfree_skb.
      benet: Call dev_kfree_skby_any instead of kfree_skb.
      gianfar: Carefully free skbs in functions called by netpoll.

 drivers/net/bonding/bond_3ad.c                  |    2 +-
 drivers/net/bonding/bond_alb.c                  |    2 +-
 drivers/net/bonding/bond_main.c                 |   14 +++++++-------
 drivers/net/ethernet/broadcom/bcm63xx_enet.c    |    4 ++--
 drivers/net/ethernet/broadcom/bnx2.c            |   10 +++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 +-
 drivers/net/ethernet/broadcom/tg3.c             |   14 +++++++-------
 drivers/net/ethernet/emulex/benet/be_main.c     |    2 +-
 drivers/net/ethernet/freescale/gianfar.c        |    6 +++---
 drivers/net/ethernet/intel/e1000/e1000_main.c   |   18 +++++++++---------
 drivers/net/ethernet/intel/igbvf/netdev.c       |    2 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c     |    6 +++---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      |    2 +-
 13 files changed, 42 insertions(+), 42 deletions(-)

Eric
