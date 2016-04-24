From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 0/6] net: core: remove TX_LOCKED support
Date: Sun, 24 Apr 2016 21:38:08 +0200
Message-ID: <1461526694-11367-1-git-send-email-fw@strlen.de>
Cc: linux-kernel@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Not that many users left, lets kill it.

 TX_LOCKED was meant to be used by LLTX drivers when spin_trylock()
 failed.  Stack then re-queued if collisions happened on different
 cpus or free'd the skb to prevent deadlocks.

 Most of the driver removal patches fall into one of three categories:
 1. remove the driver-private tx lock (and LLTX flag), or...
 2. convert spin_trylock to plain spin_lock, or...
 3. convert TX_LOCKED to free+TX_OK

 Patches are grouped by these categories, last patch is the actual removal.
 All driver changes were compile tested only with exception of atl1e.

 Documentation/networking/netdev-features.txt         |   10 ++---
 Documentation/networking/netdevices.txt              |    9 +----
 drivers/infiniband/hw/nes/nes_nic.c                  |   13 ++-----
 drivers/net/ethernet/amd/7990.c                      |    8 ++--
 drivers/net/ethernet/amd/a2065.c                     |    7 +---
 drivers/net/ethernet/atheros/atl1c/atl1c.h           |    3 -
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c      |   11 ------
 drivers/net/ethernet/atheros/atl1e/atl1e.h           |    1 
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c      |   12 -------
 drivers/net/ethernet/chelsio/cxgb/sge.c              |    3 -
 drivers/net/ethernet/dec/tulip/de4x5.c               |    7 ++--
 drivers/net/ethernet/neterion/s2io.c                 |    9 -----
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c |    6 +--
 drivers/net/ethernet/tehuti/tehuti.c                 |    8 ----
 drivers/net/hamradio/baycom_epp.c                    |    6 ++-
 drivers/net/hamradio/hdlcdrv.c                       |    6 ++-
 drivers/net/rionet.c                                 |    6 ---
 include/linux/netdevice.h                            |    3 -
 net/core/net-procfs.c                                |    3 +
 net/core/pktgen.c                                    |    1 
 net/sched/sch_generic.c                              |   32 -------------------
 21 files changed, 43 insertions(+), 121 deletions(-)
