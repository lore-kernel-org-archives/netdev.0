From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 12 Dec 2014 16:02:24 -0500 (EST)
Message-ID: <20141212.160224.1795206487557846408.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Small follow-up to the main merge pull from the other day:

1) Alexander Duyck's DMA memory barrier patch set.

2) cxgb4 driver fixes from Karen Xie.

3) Add missing export of fixed_phy_register() to modules, from Mark
   Salter.

4) DSA bug fixes from Florian Fainelli.

Please pull, thanks a lot!

The following changes since commit 70e71ca0af244f48a5dcf56dc435243792e3a495:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next (2014-12-11 14:27:06 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to eea3e8fde92999248863e4de93f325fcf3833a14:

  Merge branch 'gem' (2014-12-12 15:17:32 -0500)

----------------------------------------------------------------

Alexander Duyck (5):
      arch: Cleanup read_barrier_depends() and comments
      arch: Add lightweight memory barriers dma_rmb() and dma_wmb()
      r8169: Use dma_rmb() and dma_wmb() for DescOwn checks
      fm10k/igb/ixgbe: Use dma_rmb on Rx descriptor reads
      fib_trie: Fix trie balancing issue if new node pushes down existing node

Chun-Hao Lin (1):
      r8169:update rtl8168g pcie ephy parameter

Cyrille Pitchen (1):
      net/macb: add TX multiqueue support for gem

David S. Miller (5):
      Merge branch 'dsa'
      Merge branch 'dma_mb'
      Merge branch 'cxgb4'
      Merge branch 'kill_tasklet_hi_enable'
      Merge branch 'gem'

Florian Fainelli (3):
      net: dsa: handle non-existing PHYs on switch internal bus
      net: dsa: propagate error code from dsa_slave_phy_setup
      net: dsa: bcm_sf2: force link for all fixed PHY devices

Hariprasad Shenai (1):
      cxgb4: Add support for QSA modules

Karen Xie (7):
      cxgb4i: fix tx immediate data credit check
      cxgb4i: fix credit check for tx_data_wr
      cxgb4/cxgb4i: set the max. pdu length in firmware
      cxgb4i: additional types of negative advice
      cxgb4i: handle non-pdu-aligned rx data
      cxgb4i: use set_wr_txq() to set tx queues
      libcxgbi: fix freeing skb prematurely

Mark Salter (1):
      net: phy: export fixed_phy_register()

Quentin Lambert (2):
      jme: replace calls to redundant function
      linux/interrupt.h: remove the definition of unused tasklet_hi_enable

Tobias Klauser (2):
      net: ethernet: smsc: Allow to select SMC91X for nios2
      net: ethernet: davicom: Allow to select DM9000 for nios2

Toshiaki Makita (1):
      vlan: Add ability to always enable TSO/UFO

 Documentation/memory-barriers.txt               |  42 ++++++
 arch/alpha/include/asm/barrier.h                |  51 +++++++
 arch/arm/include/asm/barrier.h                  |   4 +
 arch/arm64/include/asm/barrier.h                |   3 +
 arch/blackfin/include/asm/barrier.h             |  51 +++++++
 arch/ia64/include/asm/barrier.h                 |  25 ++--
 arch/metag/include/asm/barrier.h                |  19 +--
 arch/mips/include/asm/barrier.h                 |  61 +-------
 arch/powerpc/include/asm/barrier.h              |  19 ++-
 arch/s390/include/asm/barrier.h                 |   7 +-
 arch/sparc/include/asm/barrier_64.h             |   7 +-
 arch/x86/include/asm/barrier.h                  |  70 ++-------
 arch/x86/um/asm/barrier.h                       |  20 +--
 drivers/net/dsa/bcm_sf2.c                       |  23 +--
 drivers/net/ethernet/cadence/macb.c             | 456 ++++++++++++++++++++++++++++++++++++--------------------
 drivers/net/ethernet/cadence/macb.h             |  36 ++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  13 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |   2 +
 drivers/net/ethernet/davicom/Kconfig            |   2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c   |   6 +-
 drivers/net/ethernet/intel/igb/igb_main.c       |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |   9 +-
 drivers/net/ethernet/jme.c                      |  12 +-
 drivers/net/ethernet/realtek/r8169.c            |  53 +++++--
 drivers/net/ethernet/smsc/Kconfig               |   4 +-
 drivers/net/phy/fixed.c                         |   1 +
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c              | 144 +++++++++++++-----
 drivers/scsi/cxgbi/libcxgbi.c                   |   4 +-
 drivers/scsi/cxgbi/libcxgbi.h                   |   4 +-
 include/asm-generic/barrier.h                   |   8 +
 include/linux/interrupt.h                       |   6 -
 net/8021q/vlan_dev.c                            |   7 +-
 net/dsa/slave.c                                 |  16 +-
 net/ipv4/fib_trie.c                             |   3 +-
 35 files changed, 771 insertions(+), 425 deletions(-)
