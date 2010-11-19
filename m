From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 19 Nov 2010 13:00:10 -0800 (PST)
Message-ID: <20101119.130010.232750285.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some small fixes:

1) If the number of RX queues is increased then decreased we get an
   OOPS in the kobject code because we do not clean up no longer used
   kobjects properly on the decrease.  Fix from John Fastabend.

2) IGMP handling race fix in bonding from Eric Dumazet.

3) Userland build fix, rtnetlink.h needs to hide some kernel internal
   includes in __KERNEL__, from Andy Whitcroft.

4) bnx2x returns postitive errors codes by accident, from Vasiliy Kulikov.

5) ICMP code needs to fill in flow source address properly, otherwise
   wrong IPSEC rule will be matched, fix from Ulrich Weber.

6) IPV6 interface properties mistakenly exposed as jiffies instead of
   msecs.  In some cases sysfs got it right, but netlink got it wrong.
   Fix from Thomas Graf.

7) SCTP checksums handled wrong in 8169 and 8139 chips, from Shan Wei.

8) Fix IP_VS kbuild deps, from Patrick McHardy.

9) Fix HT40 support in mac80211, from Luis R. Rodriguez and Mark Mentovai

10) iovec len overflow fix in rds from Dan Rosenberg.

11) IRDA should accept zero length writes, from Wolfram Sang.

Please pull, thanks a lot!

The following changes since commit 9457b24a0955bbdd2e89220a75de69fe09501bba:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6 (2010-11-12 17:17:55 -0800)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andy Whitcroft (1):
      net: rtnetlink.h -- only include linux/netdevice.h when used by the kernel

Arnd Hannemann (1):
      b43legacy: Fix compile on ARM architecture

Christian Lamparter (1):
      carl9170: fix usb anchor wait timeout

Dan Rosenberg (1):
      rds: Integer overflow in RDS cmsg handling

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Eric Dumazet (1):
      bonding: fix a race in IGMP handling

Giuseppe Cavallaro (1):
      MAINTAINERS: Add stmmac maintainer

John Fastabend (1):
      net: zero kobject in rx_queue_release

Jussi Kivilinna (1):
      cfg80211: fix WIPHY_FLAG_IBSS_RSN bit

Ken Kawasaki (1):
      ipg.c: remove id [SUNDANCE, 0x1021]

Luis R. Rodriguez (1):
      cfg80211: fix extension channel checks to initiate communication

Mark Mentovai (1):
      cfg80211: fix can_beacon_sec_chan, reenable HT40

Namhyung Kim (1):
      3c59x: fix build failure on !CONFIG_PCI

Nicolas Kaiser (1):
      gianfar: fix signedness issue

Patrick McHardy (1):
      netfilter: fix IP_VS dependencies

Rajkumar Manoharan (4):
      ath9k_htc: Update usb device ID list
      ath9k_htc: Add new devices into AR7010
      ath9k_hw: Set proper eeprom offset for AR9287 HTC devices
      ath9k_htc: Avoid setting QoS control for non-QoS frames

Randy Dunlap (1):
      net: fix kernel-doc for sk_filter_rcu_release

Sarveshwar Bandi (1):
      be2net: Fix to avoid firmware update when interface is not open.

Shan Wei (2):
      r8169: fix checksum broken
      8139cp: fix checksum broken

Tetsuo Handa (1):
      net: Fix duplicate volatile warning.

Thomas Graf (2):
      ipv6: Expose IFLA_PROTINFO timer values in msecs instead of jiffies
      ipv6: Expose reachable and retrans timer values as msecs

Ulrich Weber (1):
      xfrm: update flowi saddr in icmp_send if unset

Vasiliy Kulikov (2):
      net: bnx2x: fix error value sign
      net: caif: spi: fix potential NULL dereference

Vivek Natarajan (1):
      ath9k: Remove pm_qos request after hw unregister.

Wolfram Sang (2):
      irda: irttp: allow zero byte packets
      net: irda: irttp: sync error paths of data- and udata-requests

 MAINTAINERS                                   |    7 +++
 drivers/net/3c59x.c                           |    6 ++-
 drivers/net/8139cp.c                          |   10 ++---
 drivers/net/benet/be_main.c                   |    6 +++
 drivers/net/bnx2x/bnx2x_main.c                |    2 +-
 drivers/net/bonding/bond_main.c               |    2 +
 drivers/net/caif/caif_spi.c                   |    4 +-
 drivers/net/gianfar.c                         |    7 +--
 drivers/net/ipg.c                             |    6 +--
 drivers/net/r8169.c                           |    3 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c  |    2 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c      |    9 ++++
 drivers/net/wireless/ath/ath9k/htc_drv_init.c |    2 +
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c |    2 +-
 drivers/net/wireless/ath/ath9k/init.c         |    3 +-
 drivers/net/wireless/ath/ath9k/reg.h          |    8 +++-
 drivers/net/wireless/ath/carl9170/usb.c       |    4 +-
 include/linux/rtnetlink.h                     |    2 +-
 include/net/cfg80211.h                        |    2 +-
 include/net/neighbour.h                       |    2 +-
 net/core/filter.c                             |    2 +-
 net/core/net-sysfs.c                          |   10 ++++-
 net/ipv4/icmp.c                               |    3 +
 net/ipv6/addrconf.c                           |   28 +++++++-----
 net/irda/irttp.c                              |   30 ++++++++++----
 net/netfilter/ipvs/Kconfig                    |    1 +
 net/rds/rdma.c                                |    2 +-
 net/wireless/chan.c                           |   54 +++++++++++++++++++++++++
 28 files changed, 164 insertions(+), 55 deletions(-)
