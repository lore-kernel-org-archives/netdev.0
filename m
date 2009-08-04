From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 04 Aug 2009 12:57:42 -0700 (PDT)
Message-ID: <20090804.125742.32009006.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47293
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754062AbZHDT5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 15:57:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) IGBVF won't pass traffic due to mis-reading of MAC setting errors.
   Fix from Alexander Duyck.

2) Regression in PPP-MP fragmentation handling, fix from Ben McKeegan.

3) PPPOE procfs support can report the final hash chain's entry
   "many times", fix from Eric Dumazet.

4) EHEA interface down doesn't unregister the NAPI context --> crash.
   Fix from Hannes Hering.

5) Transmits can happen when taking sky2 interfaces down, corrupting
   state, fix from Mike McCormack.

6) PCIe completion timeouts programmed incorrectly, and thus out
   of spec for PCIe, in IXGBE driver.  Fix from Mallikarjuna R Chilakala.

7) net_assign_generic() does memcpy(... count) instead of
   memcpy(... count * object_size), fix from Eric Dumazet.

8) pppol2tp forgets to release per-net-namespace metadata during
   module unload, leaking memory.  Fix from Eric Dumazet.

9) Several reads past end-of-array boundary fixes from Roel Kluin
   (airo, ath9k, iwlwifi, libertas, ARP, 3c515, eexpress, tulip,
   s6gmac, mISDN).

10) NETPOLL support in IXGBE doesn't consider all queues, and thus
    didn't work well.  Fix from Peter P Waskiewicz Jr.

11) IXGBE was doing:
    	adapter->flags & IXGBE_FLAG2_*
    instead of:
	adapter->flags2 & IXGBE_FLAG2_*
    Fix also from Peter P Waskiewicz Jr.

12) Coherent DMA mask not set properly in netxen driver.  Fix from
    Dhananjay Phadke.

13) MLX4 driver unmaps DMA twice by mistake, oops, fix from Yevgeny
    Petrilin.

14) Fix mISDN receive buffer size usage regression, from
    Andreas Eversberg.

15) We thought we could rely upon RTNL mutex protection for unicast
    address list changes throughout, but unfortunately ipv6 needs
    to change these things from software interrupt, so a seperate
    spinlock is needed.  Regression fixed by Jiri Pirko.

16) IP address printing docbook fix from Tobias Klauser.

17) IPV4 route reverse path filter got broken when it was converted
    into a trinary knob, fix from Stephen Hemminger.

18) ISCSI needs to use GFP_ATOMIC allocations in iscsi_offload_mesg().
    Fix from Michael Chan.

19) Missing kfree calls from Julia Lawall.

20) 3c59x build fix for gcc-3.2

21) VLB and NULL pointer check fixes in pcnet32 by Bartlomiej Zolnierkiewicz
    via Don Fry.

Please pull, thanks a lot!

The following changes since commit a33a052f19a21d727847391c8c1aff3fb221c472:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://neil.brown.name/md

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Duyck (1):
      igbvf: Allow VF driver to correctly recognize failure to set mac

Andreas Eversberg (1):
      mISDN: Fix handling of receive buffer size in L1oIP

Ben McKeegan (1):
      ppp: fix lost fragments in ppp_mp_explode() (resubmit)

Dan Carpenter (1):
      wireless: ERR_PTR vs null

Dave Young (1):
      bluetooth: rfcomm_init bug fix

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Dhananjay Phadke (1):
      netxen: fix coherent dma mask setting

Don Fry (2):
      pcnet32: remove superfluous NULL pointer check in pcnet32_probe1()
      pcnet32: VLB support fixes

Eric Dumazet (3):
      pppoe: fix /proc/net/pppoe
      pppol2tp: calls unregister_pernet_gen_device() at unload time
      net: net_assign_generic() fix

Hannes Hering (1):
      ehea: Fix napi list corruption on ifconfig down

Jean Delvare (1):
      3c59x: Fix build failure with gcc 3.2

Jiajun Wu (1):
      gianfar: fix coalescing setup in ethtool support

Jiri Pirko (1):
      net: restore the original spinlock to protect unicast list

Johannes Berg (3):
      iwlwifi: fix TX queue race
      mac80211: fix suspend
      cfg80211: add two missing NULL pointer checks

Julia Lawall (3):
      net/netlabel: Add kmalloc NULL tests
      drivers/net/wireless/iwlwifi: introduce missing kfree
      drivers/net/wireless: introduce missing kfree

Luis R. Rodriguez (2):
      mac80211: do not queue work after suspend in the dynamic ps timer
      cfg80211: fix regression on beacon world roaming feature

Mallikarjuna R Chilakala (1):
      ixgbe: Patch to modify 82598 PCIe completion timeout values

Michael Chan (1):
      iscsi: Use GFP_ATOMIC in iscsi_offload_mesg().

Mike McCormack (1):
      sky2: Avoid transmits during sky2_down()

Patrick Simmons (1):
      zd1211rw: fix unaligned access in zd_mac_rx

Peter P Waskiewicz Jr (3):
      ixgbe: Fix netpoll to be properly multiqueue aware
      ixgbe: Fix usage of second flags bitmap when using LRO/RSC
      ixgbe: Fix RSC completion delay causing Rx interrupts to stop

Reinette Chatre (1):
      iwlagn: do not send key clear commands when rfkill enabled

Roel Kluin (6):
      airo: Buffer overflow
      ath9k: Read outside array bounds
      iwlwifi: Read outside array bounds
      libertas: Read outside array bounds
      libertas: Read buffer overflow
      libertas: Read buffer overflow

Stephen Hemminger (1):
      ip: fix logic of reverse path filter sysctl

Tobias Klauser (1):
      docbook: fix printk of ip address

Yevgeny Petrilin (1):
      mlx4_en: Fix double pci unmapping.

reinette chatre (1):
      iwlagn: fix minimum number of queues setting

roel kluin (6):
      3c515: Write outside array bounds
      ipv4: ARP neigh procfs buffer overflow
      eexpress: Read buffer overflow
      tulip: Read buffer overflow
      s6gmac: Read buffer overflow
      mISDN: Read buffer overflow

 Documentation/DocBook/kernel-hacking.tmpl    |    4 +-
 drivers/isdn/mISDN/l1oip_core.c              |    6 +-
 drivers/net/3c515.c                          |    4 +-
 drivers/net/3c59x.c                          |   10 ++--
 drivers/net/eexpress.c                       |    6 +-
 drivers/net/ehea/ehea.h                      |    2 +-
 drivers/net/ehea/ehea_main.c                 |    3 +
 drivers/net/gianfar_ethtool.c                |   10 ++--
 drivers/net/igbvf/vf.c                       |    4 ++
 drivers/net/ixgbe/ixgbe.h                    |    2 +
 drivers/net/ixgbe/ixgbe_82598.c              |   67 +++++++++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_ethtool.c            |   11 +++--
 drivers/net/ixgbe/ixgbe_main.c               |   25 ++++++----
 drivers/net/ixgbe/ixgbe_type.h               |    8 +++
 drivers/net/mlx4/en_tx.c                     |    1 +
 drivers/net/netxen/netxen_nic_main.c         |   37 ++++++++++-----
 drivers/net/pcnet32.c                        |   30 +++++------
 drivers/net/ppp_generic.c                    |   34 +++++++------
 drivers/net/pppoe.c                          |    1 +
 drivers/net/pppol2tp.c                       |    1 +
 drivers/net/s6gmac.c                         |    2 +-
 drivers/net/sky2.c                           |   14 +++++-
 drivers/net/sky2.h                           |    1 +
 drivers/net/tulip/de4x5.c                    |    6 +-
 drivers/net/wireless/airo.c                  |   13 ++---
 drivers/net/wireless/ath/ath9k/eeprom.c      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h      |    2 +-
 drivers/net/wireless/iwlwifi/iwl-core.c      |    3 +
 drivers/net/wireless/iwlwifi/iwl-debugfs.c   |   12 ++--
 drivers/net/wireless/iwlwifi/iwl-dev.h       |    6 ++-
 drivers/net/wireless/iwlwifi/iwl-sta.c       |   12 +++++
 drivers/net/wireless/iwlwifi/iwl-tx.c        |   14 +++--
 drivers/net/wireless/iwlwifi/iwl3945-base.c  |    7 ++-
 drivers/net/wireless/iwmc3200wifi/commands.c |    1 +
 drivers/net/wireless/iwmc3200wifi/netdev.c   |    6 +--
 drivers/net/wireless/libertas/11d.c          |    2 +-
 drivers/net/wireless/libertas/assoc.c        |   18 +++----
 drivers/net/wireless/libertas/scan.c         |    3 +-
 drivers/net/wireless/zd1211rw/zd_mac.c       |    2 +-
 drivers/scsi/scsi_transport_iscsi.c          |    4 +-
 include/linux/inetdevice.h                   |    2 +-
 include/net/bluetooth/rfcomm.h               |   12 ++++-
 include/net/cfg80211.h                       |    5 ++
 net/bluetooth/rfcomm/core.c                  |   27 +++++++---
 net/bluetooth/rfcomm/sock.c                  |    2 +-
 net/core/dev.c                               |   25 ++++++----
 net/core/net_namespace.c                     |    2 +-
 net/ipv4/arp.c                               |    4 +-
 net/mac80211/mlme.c                          |    2 +-
 net/mac80211/pm.c                            |   24 ++++++----
 net/mac80211/rx.c                            |   12 +++++
 net/netlabel/netlabel_kapi.c                 |    2 +-
 net/wireless/reg.c                           |    9 ++--
 net/wireless/reg.h                           |    3 +-
 net/wireless/scan.c                          |    4 +-
 55 files changed, 366 insertions(+), 167 deletions(-)
