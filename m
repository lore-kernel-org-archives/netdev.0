From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 24 Sep 2014 15:41:30 -0400 (EDT)
Message-ID: <20140924.154130.864183320703825399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here is a quick pull request primarily meant to address the deconfig
fallout from changing SCSI_NETLINK from being used via 'select' to
being used via 'depends'.

I applied a set of 5 patches written by Michal Marek, and then I
carefully audited all of the remaining config files, basically:

1) I scanned every arch config file, and if it mentioned CONFIG_INET or
   CONFIG_UNIX, I made sure it had CONFIG_NET=y

2) After that, I scanned every arch config file, and if it did not
   have CONFIG_NET=y I made sure it did not reference any networking
   config options.

Finally, we have some late breaking wireless fixes in here from
John Linville and co.

Please pull, sorry for the config mess, and thanks a lot!

The following changes since commit 98f75b8291a89ba6bf73e322ee467ce0bfeb91c1:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-09-22 18:23:33 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 35607b02dbef304fa5037236a3b43c1d8ab2aa52:

  sparc: bpf_jit: fix loads from negative offsets (2014-09-24 15:04:07 -0400)

----------------------------------------------------------------
Alexei Starovoitov (1):
      sparc: bpf_jit: fix loads from negative offsets

Christophe Ricard (2):
      NFC: st21nfcb: Fix depmod dependency cycle
      NFC: st21nfca: Fix potential depmod dependency cycle

Dan Carpenter (1):
      NFC: microread: Potential overflows in microread_target_discovered()

David S. Miller (5):
      mips: Update some more defconfigs which were missing CONFIG_NET.
      s390: Update defconfigs which were missing CONFIG_NET.
      powerpc: Update defconfigs which were missing CONFIG_NET.
      parisc: Update defconfigs which were missing CONFIG_NET.
      Merge tag 'master-2014-09-23' of git://git.kernel.org/.../linville/wireless

Emil Goode (1):
      brcmfmac: Fix off by one bug in brcmf_count_20mhz_channels()

John W. Linville (1):
      Merge tag 'nfc-fixes-3.17-1' of git://git.kernel.org/.../sameo/nfc-fixes

Loic Poulain (1):
      net: rfkill: gpio: Fix clock status

Michal Marek (5):
      mips: Set CONFIG_NET=y in defconfigs
      parisc: Set CONFIG_NET=y in defconfigs
      powerpc: Set CONFIG_NET=y in defconfigs
      sh: Set CONFIG_NET=y in defconfigs
      sparc: Set CONFIG_NET=y in defconfigs

Wojciech Dubowik (1):
      ath9k: Fix NULL pointer dereference on early irq

 arch/mips/configs/gpr_defconfig                       |  1 +
 arch/mips/configs/ip27_defconfig                      |  1 +
 arch/mips/configs/jazz_defconfig                      |  1 +
 arch/mips/configs/loongson3_defconfig                 |  1 +
 arch/mips/configs/malta_defconfig                     |  1 +
 arch/mips/configs/malta_kvm_defconfig                 |  1 +
 arch/mips/configs/malta_kvm_guest_defconfig           |  1 +
 arch/mips/configs/mtx1_defconfig                      |  1 +
 arch/mips/configs/nlm_xlp_defconfig                   |  1 +
 arch/mips/configs/nlm_xlr_defconfig                   |  1 +
 arch/mips/configs/rm200_defconfig                     |  1 +
 arch/parisc/configs/a500_defconfig                    |  1 +
 arch/parisc/configs/c8000_defconfig                   |  1 +
 arch/powerpc/configs/c2k_defconfig                    |  1 +
 arch/powerpc/configs/pmac32_defconfig                 |  1 +
 arch/powerpc/configs/ppc64_defconfig                  |  1 +
 arch/powerpc/configs/ppc64e_defconfig                 |  1 +
 arch/powerpc/configs/pseries_defconfig                |  1 +
 arch/powerpc/configs/pseries_le_defconfig             |  1 +
 arch/s390/configs/default_defconfig                   |  1 +
 arch/s390/configs/gcov_defconfig                      |  1 +
 arch/s390/configs/performance_defconfig               |  1 +
 arch/s390/configs/zfcpdump_defconfig                  |  1 +
 arch/s390/defconfig                                   |  1 +
 arch/sh/configs/sdk7780_defconfig                     |  1 +
 arch/sh/configs/sh2007_defconfig                      |  1 +
 arch/sparc/configs/sparc64_defconfig                  |  1 +
 arch/sparc/net/bpf_jit_asm.S                          |  3 +++
 arch/sparc/net/bpf_jit_comp.c                         |  2 +-
 drivers/net/wireless/ath/ath9k/main.c                 |  2 +-
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |  2 +-
 drivers/nfc/microread/microread.c                     | 16 ++++++++++++----
 drivers/nfc/st21nfca/Makefile                         |  5 +++--
 drivers/nfc/st21nfcb/Makefile                         |  5 +++--
 net/rfkill/rfkill-gpio.c                              |  2 +-
 35 files changed, 52 insertions(+), 12 deletions(-)
