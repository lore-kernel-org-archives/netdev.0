From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 07 Jul 2010 18:35:38 -0700 (PDT)
Message-ID: <20100707.183538.236240845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix missing length checks in ETHTOOL_* command handling, from Ben
   Hutchings.

2) Disable netpoll support for bond interfaces, it's a feature we
   tried to add this merge window and we can't make it work properly
   without major locking changes.  From Andy Gospodarek.

3) XFRMA_MARK attribute extraction uses wrong sizeof() in memcpy(),
   fix from Andreas Steffen.

4) ll_temac driver leaks iomaps on error, from Denis Kirjanov.

5) Bridge injection into IPV4 stack crashes because it fails to
   clear out the SKB control block, fix from Herbert Xu.

   Also, handle correctly the case where we have no bridging multicast
   table and see an IGMP.  People have reported crashes due to this.

6) Bonding driver can babble excessively in certain configurations
   because it sends out pointless notifications when the MAC address
   of a client hasn't even changed.  Fix from Flavio Leitner.

7) rndis_host status polling change broke some chips, revert.
   From Ben Hutchings.

8) netif_vdbg() is bogusly defined when VERBOSE_DEBUG is enabled.
   Also from Ben Hutchings.

9) qlge driver timer crash fixes, from Breno Leitao.

10) netfilter ipv6 REJECT module leaks routes, fix from Eric Dumazet.

11) Fix bogus statistic reporting in s2io driver, previously it was possible
    (for example) to see more multicast RX than total RX.  Fix from
    Jon Mason.

12) SB1250 fails to initialize module owner, from Ralf Baechle.

13) virtio net fixes from Michael S. Tsirkin, including a fix for
    infinite rx refilling and error handling in polling.

    As well as a TX oom handling fix from Rusty.

14) vxge driver shows probe time driver info using KERN_CRIT, fix
    from Wu Fengguang.

15) A few small wireless fixes via Wey-Yi Guy, Vasanthakumar Thiagarajan,
    and Johannes Berg.

16) Drivers that modify ->real_num_tx_queues on a potentially active
    interface must flush the attached qdisc or we get illegal accesses
    later, from John Fastabend.

Please pull, thanks a lot!

The following changes since commit 815c4163b6c8ebf8152f42b0a5fd015cfdcedc78:

  Linux 2.6.35-rc4 (2010-07-04 20:22:50 -0700)

are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andreas Steffen (1):
      xfrm: fix XFRMA_MARK extraction in xfrm_mark_get

Andy Gospodarek (2):
      bonding: prevent netpoll over bonded interfaces
      ixgbe: fix panic when shutting down system with WoL enabled

Ben Hutchings (5):
      ethtool: Fix potential kernel buffer overflow in ETHTOOL_GRXCLSRLALL
      ethtool: Fix potential user buffer overflow for ETHTOOL_{G, S}RXFH
      net: Revert "rndis_host: Poll status channel before control channel"
      usbnet: Set parent device early for netdev_printk()
      net: Fix definition of netif_vdbg() when VERBOSE_DEBUG is defined

Breno Leitao (2):
      qlge: Replacing add_timer() to mod_timer()
      qlge: fix a eeh handler to not add a pending timer

Cody Rester (1):
      drivers: bluetooth: bluecard_cs.c: Fixed include error, changed to linux/io.h

David Howells (1):
      Bluetooth: Fix abuse of the preincrement operator

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'vhost-net' of git://git.kernel.org/.../mst/vhost

Denis Kirjanov (1):
      ll_temac: Fix missing iounmaps

Eric Dumazet (1):
      netfilter: ip6t_REJECT: fix a dst leak in ipv6 REJECT

Flavio Leitner (1):
      bonding: check if clients MAC addr has changed

Guillaume Gaudonville (1):
      ixgbe: skip non IPv4 packets in ATR filter

Herbert Xu (2):
      bridge br_multicast: BUG: unable to handle kernel NULL pointer dereference
      bridge: Clear IPCB before possible entry into IP stack

Johannes Berg (1):
      iwlwifi: fix multicast

John Fastabend (3):
      ixgbe: disable tx engine before disabling tx laser
      sched: qdisc_reset_all_tx is calling qdisc_reset without qdisc_lock
      net: decreasing real_num_tx_queues needs to flush qdisc

Jon Mason (1):
      s2io: resolve statistics issues

Kulikov Vasiliy (1):
      net/ne: fix memory leak in ne_drv_probe()

Michael S. Tsirkin (3):
      vhost: break out of polling loop on error
      vhost: add unlikely annotations to error path
      virtio_net: do not reschedule rx refill forever

Peter Kosyh (1):
      xfrm: fix xfrm by MARK logic

Ralf Baechle (1):
      NET: SB1250: Initialize .owner

Randy Dunlap (1):
      linux/net.h: fix kernel-doc warnings

Rusty Russell (1):
      virtio_net: fix oom handling on tx

Saeed Bishara (1):
      mv643xx_eth: use sw csum for big packets

Vasanthakumar Thiagarajan (1):
      ath9k: Fix bug in starting ani

Wey-Yi Guy (1):
      iwlwifi: set TX_CMD_FLAG_PROT_REQUIRE_MSK in tx_flag

Wu Fengguang (1):
      vxge: show startup message with KERN_INFO

 drivers/bluetooth/bluecard_cs.c             |    2 +-
 drivers/bluetooth/hci_bcsp.c                |    2 +-
 drivers/net/bonding/bond_alb.c              |    3 +-
 drivers/net/bonding/bond_main.c             |   33 ++++++---
 drivers/net/ixgbe/ixgbe_main.c              |   17 +++--
 drivers/net/ll_temac_main.c                 |   18 ++++--
 drivers/net/mv643xx_eth.c                   |    9 ++-
 drivers/net/ne.c                            |    4 +-
 drivers/net/qlge/qlge_main.c                |   11 ++--
 drivers/net/s2io.c                          |  101 +++++++++++++++++----------
 drivers/net/s2io.h                          |    4 -
 drivers/net/sb1250-mac.c                    |    1 +
 drivers/net/usb/rndis_host.c                |   18 ++---
 drivers/net/usb/usbnet.c                    |    5 +-
 drivers/net/virtio_net.c                    |   28 ++++---
 drivers/net/vxge/vxge-main.c                |    4 +-
 drivers/net/wireless/ath/ath9k/ath9k.h      |    1 +
 drivers/net/wireless/ath/ath9k/main.c       |   11 +++-
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c |    6 +--
 drivers/net/wireless/iwlwifi/iwl-core.c     |    7 ++-
 drivers/vhost/net.c                         |   12 +++-
 drivers/vhost/vhost.c                       |   86 ++++++++++++-----------
 drivers/vhost/vhost.h                       |    8 +-
 include/linux/ethtool.h                     |    2 +
 include/linux/mv643xx_eth.h                 |    5 ++
 include/linux/net.h                         |    3 +-
 include/linux/netdevice.h                   |    5 +-
 include/net/sch_generic.h                   |   20 ++++-
 include/net/xfrm.h                          |    2 +-
 net/bridge/br_multicast.c                   |   21 +++---
 net/bridge/br_netfilter.c                   |    3 +
 net/core/dev.c                              |   18 +++++
 net/core/ethtool.c                          |   41 ++++++++---
 net/ipv4/xfrm4_policy.c                     |    2 +
 net/ipv6/netfilter/ip6t_REJECT.c            |    6 +-
 net/ipv6/xfrm6_policy.c                     |    2 +
 36 files changed, 332 insertions(+), 189 deletions(-)
