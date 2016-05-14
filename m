From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 14 May 2016 16:16:00 -0400 (EDT)
Message-ID: <20160514.161600.885146107956523790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix mvneta/bm dependencies, from Arnd Bergmann.

2) RX completion hw bug workaround in bnxt_en, from Michael Chan.

3) Kernel pointer leak in nf_conntrack, from Linus.

4) Hoplimit route attribute limits not enforced properly, from
   Paolo Abeni.

5) qlcnic driver NULL deref fix from Dan Carpenter.

Please pull, thanks a lot!

The following changes since commit 685764b108a7e5fe9f5ee213d6a627c1166d7c88:

  Merge tag 'scsi-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi (2016-05-11 13:17:12 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 98397fc547e3f4553553a30ea56fa34d613f0a4c:

  arm64: bpf: jit JMP_JSET_{X,K} (2016-05-14 16:11:45 -0400)

----------------------------------------------------------------
Arnd Bergmann (1):
      net: mvneta: bm: fix dependencies again

Dan Carpenter (1):
      qlcnic: potential NULL dereference in qlcnic_83xx_get_minidump_template()

David S. Miller (2):
      Merge branch 'bnxt_en-fixes'
      Merge branch 'xgene-fixes'

Iyappan Subramanian (5):
      drivers: net: xgene: fix IPv4 forward crash
      drivers: net: xgene: fix sharing of irqs
      drivers: net: xgene: fix ununiform latency across queues
      drivers: net: xgene: fix statistics counters race condition
      drivers: net: xgene: fix register offset

Linus Torvalds (1):
      nf_conntrack: avoid kernel pointer value leak in slab name

Michael Chan (2):
      bnxt_en: Add workaround to detect bad opaque in rx completion (part 1)
      bnxt_en: Add workaround to detect bad opaque in rx completion (part 2)

Paolo Abeni (1):
      net/route: enforce hoplimit max value

Paul Durrant (1):
      xen-netback: fix extra_info handling in xenvif_tx_err()

Zi Shen Lim (1):
      arm64: bpf: jit JMP_JSET_{X,K}

 arch/arm64/net/bpf_jit_comp.c                        |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.c      | 11 +++++-----
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.h      |  2 ++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c       | 19 ++++++++++-------
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h       |  8 ++++---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c     | 75 +++++++++++++++++++++++++++++++++++++++++++++++------------------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h     | 18 ++++++++++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h    |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c            | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h            |  2 ++
 drivers/net/ethernet/marvell/Kconfig                 |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c |  8 +++++--
 drivers/net/xen-netback/netback.c                    |  1 +
 net/ipv4/fib_semantics.c                             |  2 ++
 net/ipv6/route.c                                     |  2 ++
 net/netfilter/nf_conntrack_core.c                    |  4 +++-
 16 files changed, 175 insertions(+), 45 deletions(-)
