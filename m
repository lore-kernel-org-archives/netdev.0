From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH next-next 0/10] Using dev_kfree_skb_any for functions called in multiple contexts
Date: Tue, 11 Mar 2014 14:13:56 -0700
Message-ID: <87r468bfqj.fsf_-_@xmission.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56055 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753782AbaCKVOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 17:14:04 -0400
In-Reply-To: <20140311.160931.1395978386605601765.davem@davemloft.net> (David
	Miller's message of "Tue, 11 Mar 2014 16:09:31 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patchset should be an uncontroversial set of changes to change
dev_kfree_skb to dev_kfree_skb_any for code paths that are called in
hard irq contexts in addition to other contexts.  netpoll is the reason
this code gets called in multiple contexts.

There is more coming but these changes are a good starting place, and
stand on their own.

Since the last round changes to the rx path have been removed netpoll
will changed to avoid that.

Eric W. Biederman (10):
      8139cp: Call dev_kfree_skby_any instead of kfree_skb.
      8139too: Call dev_kfree_skby_any instead of dev_kfree_skb.
      r8169: Call dev_kfree_skby_any instead of dev_kfree_skb.
      bonding: Call dev_kfree_skby_any instead of kfree_skb.
      bnx2: Call dev_kfree_skby_any instead of dev_kfree_skb.
      tg3: Call dev_kfree_skby_any instead of dev_kfree_skb.
      ixgb: Call dev_kfree_skby_any instead of dev_kfree_skb.
      mlx4: Call dev_kfree_skby_any instead of dev_kfree_skb.
      benet: Call dev_kfree_skby_any instead of kfree_skb.
      gianfar: Carefully free skbs in functions called by netpoll.


 drivers/net/bonding/bond_3ad.c              |    2 +-
 drivers/net/bonding/bond_alb.c              |    2 +-
 drivers/net/bonding/bond_main.c             |   10 +++++-----
 drivers/net/ethernet/broadcom/bnx2.c        |    6 +++---
 drivers/net/ethernet/broadcom/tg3.c         |   14 +++++++-------
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 drivers/net/ethernet/freescale/gianfar.c    |    4 ++--
 drivers/net/ethernet/intel/ixgb/ixgb_main.c |    6 +++---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c  |    2 +-
 drivers/net/ethernet/realtek/8139cp.c       |    2 +-
 drivers/net/ethernet/realtek/8139too.c      |    4 ++--
 drivers/net/ethernet/realtek/r8169.c        |    6 +++---
 12 files changed, 30 insertions(+), 30 deletions(-)

Eric
