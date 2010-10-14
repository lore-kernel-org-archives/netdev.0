From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 14 Oct 2010 10:14:36 -0700 (PDT)
Message-ID: <20101014.101436.193725247.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


One last push before heading off to Spain for the netfilter workshop:

1) r8169 does 16K allocations using GFP_ATOMIC during resume,
   which makes resume fail frequently.  Use dma_*() interfaces
   and GFP_KERNEL where possible.

   From Stanislaw Gruszka.

2) b44 and fec driver mis-manage initial carrier state, breaking NFS
   root mounts and similar, from Paul Fertser and Oskar Schirmer.

3) Kernel heap leak to userspace in privileged ethtool ops, fix from
   Kees Cook.

4) Several use-after free fixes in ATM and wimax from Jiri Slaby.

5) Fixed PHY support regressed upon conversion to phylib in FEC
   driver, fix from Greg Ungerer.

6) ehea sets CHECKSUM_UNNECESSARY erroneously on non-TCP/UDP packets,
   fix from Breno Leitao.

7) TG3 rx_dropped accounting regressed unintentionally, fix from Eric
   Dumazet.

Please pull, thanks a lot!

The following changes since commit 53eeb64e808971207350386121f4bab12fa2f45f:
  Linus Torvalds (1):
        Merge branch 'fixes' of git://git.kernel.org/.../djbw/async_tx

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Breno Leitao (1):
      ehea: Fix a checksum issue on the receive path

Eric Dumazet (1):
      tg3: restore rx_dropped accounting

Greg Ungerer (1):
      net: allow FEC driver to use fixed PHY support

Jiri Slaby (4):
      ATM: solos-pci, remove use after free
      ATM: mpc, fix use after free
      ATM: iphase, remove sleep-inside-atomic
      NET: wimax, fix use after free

Kees Cook (1):
      net: clear heap allocations for privileged ethtool actions

Oskar Schirmer (1):
      net/fec: carrier off initially to avoid root mount failure

Paul Fertser (1):
      b44: fix carrier detection on bind

Stanislaw Gruszka (2):
      r8169: allocate with GFP_KERNEL flag when able to sleep
      r8169: use device model DMA API

 drivers/atm/iphase.c          |    6 ----
 drivers/atm/iphase.h          |    2 +-
 drivers/atm/solos-pci.c       |    8 +++--
 drivers/net/b44.c             |    4 +-
 drivers/net/ehea/ehea_main.c  |    9 +++++-
 drivers/net/ehea/ehea_qmr.h   |    1 +
 drivers/net/fec.c             |   44 +++++++++++++++++++---------
 drivers/net/r8169.c           |   65 ++++++++++++++++++++++-------------------
 drivers/net/tg3.c             |    6 ++-
 drivers/net/tg3.h             |    2 +-
 drivers/net/wimax/i2400m/rx.c |   26 ++++++++--------
 net/atm/mpc.c                 |    2 +-
 net/core/ethtool.c            |    6 ++--
 13 files changed, 104 insertions(+), 77 deletions(-)
