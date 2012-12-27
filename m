From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 26 Dec 2012 19:44:11 -0800 (PST)
Message-ID: <20121226.194411.495144165867210013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37729 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743Ab2L0DoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 22:44:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) GRE tunnel drivers don't set the transport header properly, they
   also blindly deref the inner protocol ipv4 and needs some checks.
   Fixes from Isaku Yamahata.

2) Fix sleeps while atomic in netdevice rename code, from Eric
   Dumazet.

3) Fix double-spinlock in solos-pci driver, from Dan Carpenter.

4) More ARP bug fixes.  Fix lockdep splat in arp_solicit() and
   then the bug accidently added by that fix.  From Eric Dumazet
   and Cong Wang.

5) Remove some __dev* annotations that slipped back in, as well
   as all HOTPLUG references.  From Greg KH

6) RDS protocol uses wrong interfaces to access scatter-gather
   elements, causing a regression.  From Mike Marciniszyn.

7) Fix build error in cpts driver, from Richard Cochran.

8) Fix arithmetic in packet scheduler, from Stefan Hasko.

9) Similarly, fix association during calculation of random
   backoff in batman-adv.  From Akinobu Mita.

Please pull, thanks a lot!

The following changes since commit c4271c6e37c32105492cbbed35f45330cb327b94:

  NFS: Kill fscache warnings when mounting without -ofsc (2012-12-21 08:32:09 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to ae782bb16c35ce27512beeda9be6024c88f85b08:

  ipv6/ip6_gre: set transport header correctly (2012-12-26 15:19:56 -0800)

----------------------------------------------------------------
Akinobu Mita (1):
      batman-adv: fix random jitter calculation

Cong Wang (1):
      arp: fix a regression in arp_solicit()

Dan Carpenter (1):
      solos-pci: double lock in geos_gpio_store()

Eric Dumazet (5):
      ip_gre: fix possible use after free
      net: devnet_rename_seq should be a seqcount
      tuntap: dont use a private kmem_cache
      ipv4: arp: fix a lockdep splat in arp_solicit()
      tcp: should drop incoming frames without ACK flag set

Gao feng (1):
      bridge: call br_netpoll_disable in br_add_if

Greg KH (2):
      Drivers: network: more __dev* removal
      CONFIG_HOTPLUG removal from networking core

Isaku Yamahata (3):
      ip_gre: make ipgre_tunnel_xmit() not parse network header as IP unconditionally
      ipv4/ip_gre: set transport header correctly to gre header
      ipv6/ip6_gre: set transport header correctly

Li Zefan (1):
      netprio_cgroup: define sk_cgrp_prioidx only if NETPRIO_CGROUP is enabled

Marciniszyn, Mike (2):
      IB/rds: Correct ib_api use with gs_dma_address/sg_dma_len
      IB/rds: suppress incompatible protocol when version is known

Richard Cochran (2):
      cpts: fix build error by removing useless code.
      cpts: fix a run time warn_on.

Stefan Hasko (1):
      net: sched: integer overflow fix

Yan Burman (1):
      net/vxlan: Use the underlying device index when joining/leaving multicast groups

 drivers/atm/solos-pci.c                     |  2 +-
 drivers/net/ethernet/marvell/mvmdio.c       |  6 +++---
 drivers/net/ethernet/marvell/mvneta.c       | 19 +++++++++----------
 drivers/net/ethernet/ti/cpts.c              |  3 +--
 drivers/net/ethernet/ti/cpts.h              |  1 -
 drivers/net/tun.c                           | 24 +++---------------------
 drivers/net/vxlan.c                         |  6 ++++--
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c |  2 +-
 include/linux/netdevice.h                   |  2 +-
 include/net/sock.h                          |  2 +-
 net/batman-adv/bat_iv_ogm.c                 |  2 +-
 net/bridge/br_if.c                          |  8 +++++---
 net/core/dev.c                              | 18 +++++++++---------
 net/core/net-sysfs.c                        |  4 ----
 net/core/sock.c                             |  4 ++--
 net/ipv4/arp.c                              | 10 ++++------
 net/ipv4/ip_gre.c                           | 13 ++++++++++---
 net/ipv4/tcp_input.c                        | 14 ++++++++++----
 net/ipv6/ip6_gre.c                          |  3 +--
 net/rds/ib_cm.c                             | 11 +++++------
 net/rds/ib_recv.c                           |  9 ++++++---
 net/sched/sch_htb.c                         |  2 +-
 net/wireless/reg.c                          |  7 -------
 net/wireless/sysfs.c                        |  4 ----
 24 files changed, 78 insertions(+), 98 deletions(-)
