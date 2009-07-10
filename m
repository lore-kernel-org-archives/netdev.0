From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Thu, 09 Jul 2009 20:17:51 -0700 (PDT)
Message-ID: <20090709.201751.09493544.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753246AbZGJDSA@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) FEC build fix and FEC_X_DES_ACTIVE register offset cure, from
   Greg Ungerer.

2) The socket poll vs. wake up memory ordering fix, after going
   through many revisions and discussion, seems ready to merge.
   From Jiri Olsa.

3) The netpoll carrier detection fix from Anton Vorontsov.

4) Revert fib_trie to pre-2.6.22 era root node thresholds to
   fix memory allocation overstress seen with BGP workloads.
   From Jarek Poplawski.

5) davinci_emac goes OOPS if MAC address changed while interface
   is down, fix from Pablo Bitton.

6) cxgb3 hits wrong TX queue and crashses, from Roland Dreier.

7) IGB bug fix from Alexander Duyck

8) IXGBE bug fix from Yi Zou

9) R6040 bug fixes from Florian Fainelli

10) Merge in wireless bug fixes via John Linville.

Please pull, thanks a lot!

The following changes since commit 2e3167308048ca6c810733384d8289082f7e4ec1:
  Roland Dreier (1):
        fealnx: Fix build breakage -- PR_CONT should be KERN_CONT

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Duyck (1):
      igb: set lan id prior to configuring phy

Andrey Yurovsky (1):
      mac80211: fix allocation in mesh_queue_preq

Anton Vorontsov (1):
      netpoll: Fix carrier detection for drivers that are using phylib

Clyde McPherson (2):
      b43: Add support for 4318E
      ssb: Add support for 4318E

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Florian Fainelli (2):
      r6040: restore MIER register correctly when IRQ line is shared
      r6040: bump driver version to 0.24 and date to 08 July 2009

Greg Ungerer (2):
      fec: remove extra ";" from definition names
      fec: fix definition of 5272 version of FEC_X_DES_ACTIVE register

Hin-Tak Leung (1):
      zd1211rw: adding SONY IFU-WLM2 (054c:0257) as a zd1211b device

Jarek Poplawski (1):
      ipv4: Fix fib_trie rebalancing, part 4 (root thresholds)

Jaswinder Singh Rajput (1):
      includecheck fix: include/linux, rfkill.h

Jay Sternberg (1):
      Atheros Kconfig needs to be dependent on WLAN_80211

Jiri Olsa (2):
      net: adding memory barrier to the poll and receive callbacks
      memory barrier: adding smp_mb__after_lock

Jiri Slaby (1):
      Wireless: nl80211, fix lock imbalance

Johannes Berg (4):
      hp-wmi: fix rfkill bug
      cfg80211: fix refcount leak
      mac80211_hwsim: avoid NULL access
      mac80211: fix docbook

Larry Finger (2):
      b43/b43legacy: fix radio LED initialization
      p54: tx refused but queue active

Luciano Coelho (1):
      mac80211: minstrel: avoid accessing negative indices in rix_to_ndx()

Pablo Bitton (1):
      davinci_emac: fix kernel oops when changing MAC address while interface is down

Pascal Terjan (1):
      zd1211rw: 07b8:6001 is a ZD1211B

Roland Dreier (1):
      cxgb3: Fix crash caused by stashing wrong netdev_queue

Samuel Ortiz (1):
      iwmc3200wifi: add Kconfig help

Vasanthakumar Thiagarajan (1):
      ath9k: Fix leak in tx descriptor

Yi Zou (1):
      ixgbe: Fix coexistence of FCoE and Flow Director in 82599

 Documentation/DocBook/mac80211.tmpl        |    2 -
 arch/x86/include/asm/spinlock.h            |    4 ++
 drivers/net/cxgb3/cxgb3_main.c             |    3 +-
 drivers/net/davinci_emac.c                 |   12 ++++-
 drivers/net/fec.h                          |   12 ++--
 drivers/net/igb/e1000_82575.c              |    4 ++
 drivers/net/ixgbe/ixgbe_dcb_nl.c           |    6 ++
 drivers/net/ixgbe/ixgbe_main.c             |   19 ++++---
 drivers/net/r6040.c                        |    9 ++-
 drivers/net/wireless/ath/Kconfig           |    1 +
 drivers/net/wireless/ath/ath9k/xmit.c      |    9 +++-
 drivers/net/wireless/b43/b43.h             |    1 +
 drivers/net/wireless/b43/main.c            |    7 ++-
 drivers/net/wireless/b43/pcmcia.c          |    1 +
 drivers/net/wireless/b43legacy/b43legacy.h |    1 +
 drivers/net/wireless/b43legacy/main.c      |    7 ++-
 drivers/net/wireless/iwmc3200wifi/Kconfig  |    9 ++++
 drivers/net/wireless/mac80211_hwsim.c      |    1 +
 drivers/net/wireless/p54/p54common.c       |    5 +-
 drivers/net/wireless/zd1211rw/zd_usb.c     |    3 +-
 drivers/platform/x86/hp-wmi.c              |    2 +-
 drivers/ssb/pcmcia.c                       |    6 ++-
 include/linux/rfkill.h                     |    1 -
 include/linux/spinlock.h                   |    5 ++
 include/net/sock.h                         |   69 ++++++++++++++++++++++++++++
 net/atm/common.c                           |    6 +-
 net/core/datagram.c                        |    2 +-
 net/core/netpoll.c                         |    2 +-
 net/core/sock.c                            |    8 ++--
 net/dccp/output.c                          |    2 +-
 net/dccp/proto.c                           |    2 +-
 net/ipv4/fib_trie.c                        |    4 +-
 net/ipv4/tcp.c                             |    2 +-
 net/iucv/af_iucv.c                         |    4 +-
 net/mac80211/mesh_hwmp.c                   |    2 +-
 net/mac80211/rc80211_minstrel.c            |    5 ++-
 net/rxrpc/af_rxrpc.c                       |    4 +-
 net/unix/af_unix.c                         |    8 ++--
 net/wireless/nl80211.c                     |    1 +
 net/wireless/scan.c                        |    1 -
 40 files changed, 192 insertions(+), 60 deletions(-)
