From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 02 Apr 2013 17:11:38 -0400 (EDT)
Message-ID: <20130402.171138.487778516861745347.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47288 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760340Ab3DBVLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 17:11:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix VSOCK layer handling of context ID changes, from Reilly Grant.

2) Now that we have a synchronize_net() in netdev_rx_handler_unregister(),
   we can't let any call sites hold locks.  Unfortunately bonding does,
   so we have to drop the rwlock there a little bit earlier, fix from
   Veaceslav Falico.

3) MAC address setting loop exits one iteration too early in mlx4 driver,
   from Yan Burman.

4) Restore ipv6 routes properly upon ifdown/ifup of loopback, from
   Balakumaran Kannan.

Please pull, thanks a lot!

The following changes since commit 118c9a45fdacc6fe57910fa1d048e2d5bbc193f4:

  Merge tag 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc (2013-04-02 08:35:03 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 990454b5a48babde44a23c0f22bae5523f4fdf13:

  VSOCK: Handle changes to the VMCI context ID. (2013-04-02 14:39:17 -0400)

----------------------------------------------------------------
Balakumaran Kannan (1):
      net IPv6 : Fix broken IPv6 routing table after loopback down-up

Reilly Grant (1):
      VSOCK: Handle changes to the VMCI context ID.

Vasily Averin (1):
      cbq: incorrect processing of high limits

Veaceslav Falico (1):
      bonding: get netdev_rx_handler_unregister out of locks

Yan Burman (1):
      net/mlx4_en: Fix setting initial MAC address

 drivers/net/bonding/bond_main.c                |  3 +--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  4 ++--
 net/ipv6/addrconf.c                            | 27 +++++++++++++++++++++++++++
 net/sched/sch_cbq.c                            |  5 ++++-
 net/vmw_vsock/af_vsock.c                       |  6 +++---
 net/vmw_vsock/vmci_transport.c                 | 31 ++++++++++++++++++++-----------
 net/vmw_vsock/vsock_addr.c                     | 10 ----------
 net/vmw_vsock/vsock_addr.h                     |  2 --
 8 files changed, 57 insertions(+), 31 deletions(-)
