From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 27 May 2015 14:55:52 -0400 (EDT)
Message-ID: <20150527.145552.660264294278145713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Don't use MMIO on certain iwlwifi devices otherwise we get a firmwar=
e
   crash.

2) Don't corrupt the GRO lists of mac80211 contexts by doing sends
   via timer interrupt, from Johannes Berg.

3) SKB tailroom is miscalculated in AP_VLAN crypto code, from Michal
   Kazior.

4) Fix fw_status memory leak in iwlwifi, from Haim Dreyfuss.

5) Fix use after free in iwl_mvm_d0i3_enable_tx(), from Eliad Peller.

6) JIT'ing of large BPF programs is broken on x86, from Alexei Starovoi=
tov.

7) EMAC driver ethtool register dump size is miscalculated, from Ivan
   Mikhaylov.

8) Fix PHY initial link mode when autonegotiation is disabled in amd-xg=
be,
   from Tom Lendacky.

9) Fix NULL deref on SOCK_DEAD socket in AF_UNIX and CAIF protocols, fr=
om
   Mark Salyzyn.

10) credit_bytes not initialized properly in xen-netback, from Ross
    Lagerwall.

11) Fallback from MSI-X to INTx interrupts not handled properly in mlx4
    driver, fix from Benjamin Poirier.

12) Perform ->attach() after binding dev->qdisc in packet scheduler,
    otherwise we can crash.  From Cong WANG.

13) Don't clobber data in sctp_v4_map_v6().  From Jason Gunthorpe.

Please pull, thanks a lot!

The following changes since commit cf539cbd8a81e12880735a0912de8b99f46c=
84fd:

  Merge branch 'drm-fixes' of git://people.freedesktop.org/~airlied/lin=
ux (2015-05-22 17:34:24 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git=20

for you to fetch changes up to 9302d7bb0c5cd46be5706859301f18c137b2439f=
:

  sctp: Fix mangled IPv4 addresses on a IPv6 listening socket (2015-05-=
27 14:15:26 -0400)

----------------------------------------------------------------
Alexei Starovoitov (1):
      x86: bpf_jit: fix compilation of large bpf programs

Avri Altman (1):
      iwlwifi: pcie: don't disable the busmaster DMA clock for family 8=
000

Benjamin Poirier (1):
      mlx4_core: Fix fallback from MSI-X to INTx

Daniel Borkmann (1):
      tools: bpf_jit_disasm: fix segfault on disabled debugging log out=
put

David S. Miller (3):
      Merge tag 'wireless-drivers-for-davem-2015-05-25' of git://git.ke=
rnel.org/.../kvalo/wireless-drivers
      Merge branch 'phyter-bug-fixes'
      Merge tag 'mac80211-for-davem-2015-05-26' of git://git.kernel.org=
/.../jberg/mac80211

David Vrabel (1):
      xen-netfront: properly destroy queues when removing device

Eliad Peller (1):
      iwlwifi: mvm: avoid use-after-free on iwl_mvm_d0i3_enable_tx()

Emmanuel Grumbach (4):
      iwlwifi: mvm: forbid MIMO on devices that don't support it
      iwlwifi: 7000: modify the firmware name for 3165
      iwlwifi: mvm: fix MLME trigger
      iwlwifi: mvm: BT Coex - duplicate the command if sent ASYNC

=46lorian Fainelli (1):
      net: phy: bcm7xxx: Fix 7425 PHY ID and flags

Haim Dreyfuss (1):
      iwlwifi: mvm: Free fw_status after use to avoid memory leak

Ivan Mikhaylov (1):
      net/ibm/emac: fix size of emac dump memory areas

Jason Gunthorpe (1):
      sctp: Fix mangled IPv4 addresses on a IPv6 listening socket

Johannes Berg (2):
      mac80211: don't use napi_gro_receive() outside NAPI context
      mac80211: don't split remain-on-channel for coalescing

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-05-21' of https://git.kernel.or=
g/.../iwlwifi/iwlwifi-fixes

Lendacky, Thomas (1):
      amd-xgbe-phy: Fix initial mode when autoneg is disabled

Liad Kaufman (1):
      iwlwifi: nvm: force mac from otp in case nvm mac is reserved

Luciano Coelho (2):
      iwlwifi: mvm: take the UCODE_DOWN reference when resuming
      iwlwifi: mvm: clean net-detect info if device was reset during su=
spend

Mark Salyzyn (1):
      unix/caif: sk_socket can disappear when state is unlocked

Mathieu Olivari (1):
      net: stmmac: create one debugfs dir per net-device

Michal Kazior (1):
      mac80211: fix AP_VLAN crypto tailroom calculation

Rafa=A9=A9 Mi=A9=A9ecki (1):
      ssb: extend fix for PCI related silent reboots to all chipsets

Richard Cochran (3):
      net: dp83640: fix broken calibration routine.
      net: dp83640: reinforce locking rules.
      net: dp83640: fix improper double spin locking.

Ross Lagerwall (1):
      xen/netback: Properly initialize credit_bytes

Vladimir Zapolskiy (1):
      net: netxen: correct sysfs bin attribute return code

WANG Cong (1):
      net_sched: invoke ->attach() after setting dev->qdisc

 arch/x86/net/bpf_jit_comp.c                          |  7 ++++++-
 drivers/net/ethernet/ibm/emac/core.c                 | 16 ++++++------=
---
 drivers/net/ethernet/ibm/emac/core.h                 |  7 ++-----
 drivers/net/ethernet/mellanox/mlx4/cmd.c             |  9 +++++++--
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |  6 +++---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h         |  6 ++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    | 76 ++++++++++++=
++++++++++++++++++++++++++++++++++++----------------------
 drivers/net/phy/amd-xgbe-phy.c                       | 45 ++++++++++++=
+++++++++++++++++++++++++++---
 drivers/net/phy/bcm7xxx.c                            |  2 +-
 drivers/net/phy/dp83640.c                            | 23 ++++++++++++=
++++++----
 drivers/net/wireless/iwlwifi/Kconfig                 |  1 +
 drivers/net/wireless/iwlwifi/iwl-7000.c              | 16 +++++++-----=
---
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c      |  5 +++++
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.h      |  3 +++
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c         | 30 ++++++++++++=
+++++++++-------
 drivers/net/wireless/iwlwifi/mvm/coex_legacy.c       |  2 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c                | 22 ++++++++++++=
+++------
 drivers/net/wireless/iwlwifi/mvm/mac80211.c          |  3 ---
 drivers/net/wireless/iwlwifi/mvm/ops.c               |  6 ++++--
 drivers/net/wireless/iwlwifi/mvm/rs.c                |  3 +++
 drivers/net/wireless/iwlwifi/pcie/trans.c            |  8 +++++---
 drivers/net/xen-netback/xenbus.c                     |  1 +
 drivers/net/xen-netfront.c                           | 15 ++----------=
--
 drivers/ssb/driver_pcicore.c                         |  7 ++++---
 include/linux/brcmphy.h                              |  2 +-
 include/net/sctp/sctp.h                              |  7 +++++--
 net/caif/caif_socket.c                               |  8 ++++++++
 net/mac80211/cfg.c                                   | 59 +++++++++++-=
------------------------------------------
 net/mac80211/ieee80211_i.h                           |  9 +++------
 net/mac80211/iface.c                                 |  6 ++++++
 net/mac80211/key.c                                   | 82 ++++++++++++=
+++++++++++++++++++++++++++++++++++++++++++++++++++++++---------
 net/mac80211/key.h                                   |  1 +
 net/mac80211/rx.c                                    |  5 +++--
 net/mac80211/util.c                                  |  3 +++
 net/sched/sch_api.c                                  | 10 ++++++----
 net/unix/af_unix.c                                   |  8 ++++++++
 tools/net/bpf_jit_disasm.c                           |  2 ++
 37 files changed, 351 insertions(+), 170 deletions(-)
