From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 12 May 2015 23:49:10 -0400 (EDT)
Message-ID: <20150512.234910.1591110502657064583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Handle max TX power properly wrt. VIFs and the MAC in iwlwifi,
   from Avri Altman.

2) Use the correct FW API for scan completions in iwlwifi, from
   Avraham Stern.

3) FW monitor in iwlwifi accidently uses unmapped memory, fix from
   Liad Kaufman.

4) rhashtable conversion of mac80211 station table was buggy, the
   virtual interface was not taken into account.  Fix from Johannes
   Berg.

5) Fix deadlock in rtlwifi by not using a zero timeout for
   usb_control_msg(), from Larry Finger.

6) Update reordering state before calculating loss detection, from
   Yuchung Cheng.

7) Fix off by one in bluetooth firmward parsing, from Dan Carpenter.

8) Fix extended frame handling in xiling_can driver, from Jeppe
   Ledet-Pedersen.

9) Fix CODEL packet scheduler behavior in the presence of TSO packets,
   from Eric Dumazet.

10) Fix NAPI budget testing in fm10k driver, from Alexander Duyck.

11) macvlan needs to propagate promisc settings down the the lower
    device, from Vlad Yasevich.

12) igb driver can oops when changing number of rings, from Toshiaki
    Makita.

13) Source specific default routes not handled properly in ipv6,
    from Markus Stenberg.

14) Use after free in tc_ctl_tfilter(), from WANG Cong.

15) Use softirq spinlocking in netxen driver, from Tony Camuso.

16) Two ARM bpf JIT fixes from Nicolas Schichan.

17) Handle MSG_DONTWAIT properly in ring based AF_PACKET sends, from
    Mathias Kretschmer.

18) Fix x86 bpf JIT implementation of FROM_{BE16,LE16,LE32}, from
    Alexei Starovoitov.

19) ll_temac driver DMA maps TX packet header with incorrect length,
    fix from Michal Simek.

20) We remove pm_qos bits from netdevice.h, but some indirect reference=
s
    remained.  Kill them.  From David Ahern.

Please pull, thanks a lot!

The following changes since commit 6c3c1eb3c35e8856d6dcb01b412316a676f5=
8bbe:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-0=
5-01 20:51:04 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git=20

for you to fetch changes up to 01d460dd70adc858e15307332832183c622bee50=
:

  net: Remove remaining remnants of pm_qos from netdevice.h (2015-05-12=
 23:22:03 -0400)

----------------------------------------------------------------
Alexander Aring (8):
      mac802154: fix ieee802154_register_hw error handling
      at86rf230: remove tabs after define
      at86rf230: move cal_timeout to state change
      at86rf230: add TX_ARET_ON for calibration timeout
      at86rf230: remove unnecessary tx state change
      at86rf230: change state change if from trx_off
      at86rf230: add slp_tr support to start tx
      ieee802154: trace: fix endian convertion

Alexander Bondar (1):
      iwlwifi: mvm: Avoid signal based decisions if ave beacon RSSI is =
0

Alexander Duyck (3):
      fm10k: Do not assume budget will never be 0 for NAPI
      r8169: Do not use dev_kfree_skb in xmit path
      ixgbevf: Use dev_kfree_skb_any in xmit path, not dev_kfree_skb

Alexei Starovoitov (1):
      x86: bpf_jit: fix FROM_BE16 and FROM_LE16/32 instructions

Avraham Stern (1):
      iwlwifi: mvm: fix scan iteration complete notification handling

Avri Altman (1):
      iwlwifi: mvm: fix Tx Power firmware API

Bert Vermeulen (1):
      net: mdio-gpio: Allow for unspecified bus id

Christoffer Holmstedt (1):
      at86rf230: Add macro for TRX STATE MASK

Dan Carpenter (1):
      Bluetooth: btusb: off by one in rtl8723b_parse_firmware()

Daniel Drake (1):
      Bluetooth: btusb: Add Realtek 8723A/8723B/8761A/8821A support

David Ahern (3):
      net/rds: Fix new sparse warning
      e1000e: Add pm_qos header
      net: Remove remaining remnants of pm_qos from netdevice.h

David S. Miller (10):
      Merge tag 'linux-can-fixes-for-4.1-20150501' of git://git.kernel.=
org/.../mkl/linux-can
      Merge branch 'dev_kfree_skb'
      Revert "Revert "smc91x: retrieve IRQ and trigger flags in a moder=
n way""
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth-next
      Merge tag 'mac80211-for-davem-2015-05-04' of git://git.kernel.org=
/.../jberg/mac80211
      Merge branch 'mlx4'
      Merge tag 'wireless-drivers-for-davem-2015-05-05' of git://git.ke=
rnel.org/.../kvalo/wireless-drivers
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge branch 'rds'
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net-qu=
eue

David Ward (1):
      net_sched: gred: use correct backlog value in WRED mode

DingXiang (1):
      Bluetooth: bt3c: Delete some unuseful comments

Emmanuel Grumbach (2):
      iwlwifi: mvm: don't stop the FW monitor too early
      iwlwifi: mvm: fix typo in CONFIG option

Eran Ben Elisha (1):
      net/mlx4_en: Fix off-by-one in counters manipulation

Eran Harary (1):
      iwlwifi: mvm: don't power off the device between INIT and OPER fi=
rmwares

Eric Dumazet (6):
      tcp: add tcpi_bytes_acked to tcp_info
      tcp: add tcpi_bytes_received to tcp_info
      tcp: prepare CC get_info() access from getsockopt()
      tcp: add TCP_CC_INFO socket option
      codel: fix maxpacket/mtu confusion
      tcp_westwood: fix tcp_westwood_info()

=46elix Fietkau (1):
      pppoe: drop pppoe device in pppoe_unbind_sock_work

Gabriele Mazzotta (1):
      Bluetooth: Skip the shutdown routine if the interface is not up

Guido G=FCnther (1):
      ieee802154: Add trace events for rdev->ops

Herbert Xu (2):
      netlink: Remove max_size setting
      Revert "net: kernel socket should be released in init_net namespa=
ce"

Jason A. Donenfeld (1):
      usbnet: avoid integer overflow in start_xmit

Jean Delvare (2):
      net: amd-xgbe: Add hardware dependency
      net: xgene_enet: Set hardware dependency

Jeppe Ledet-Pedersen (1):
      net: can: xilinx_can: fix extended frame handling

Jerry Snitselaar (1):
      hv_netvsc: remove unused variable in netvsc_send()

Johannes Berg (4):
      mac80211: don't warn when stopping VLAN with stations
      mac80211: fix rhashtable conversion
      mac80211: enable hash table shrinking
      iwlwifi: mvm: force quota update update after FW restart

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-04-28' of https://git.kernel.or=
g/.../iwlwifi/iwlwifi-fixes

Kamlakant Patel (1):
      net/smsc911x: fix irq resource allocation failure

Kretschmer, Mathias (1):
      af_packet / TX_RING not fully non-blocking (w/ MSG_DONTWAIT).

Larry Finger (1):
      rtlwifi: rtl8192cu: Fix kernel deadlock

Liad Kaufman (1):
      iwlwifi: pcie: prevent using unmapped memory in fw monitor

Lorenzo Bianconi (1):
      ath9k: fix per-packet tx power configuration

Marcel Holtmann (4):
      Bluetooth: btbcm: Export patchram download as separate function
      Bluetooth: hci_uart: Reorder Atheros specific driver callbacks
      Bluetooth: hci_uart: Add Atheros support for address configuratio=
n
      Bluetooth: btusb: Fix two coding style issues

Markus Stenberg (1):
      ipv6: Fixed source specific default route handling.

Michal Schmidt (1):
      bnx2x: limit fw delay in kdump to 5s after boot

Michal Simek (1):
      net: ll_temac: Fix DMA map size bug

Nathan Sullivan (1):
      net: macb: Handle the RXUBR interrupt on all devices

Nicolas Dichtel (1):
      netns: return RTM_NEWNSID instead of RTM_GETNSID on a get

Nicolas Schichan (2):
      ARM: net fix emit_udiv() for BPF_ALU | BPF_DIV | BPF_K intruction=
=2E
      ARM: net: delegate filter to kernel interpreter when imm_offset()=
 return value can't fit into 12bits.

Niklas Cassel (1):
      net: phy: micrel: Fix regression in kszphy_probe

Paul Gortmaker (1):
      drivers/net: include <module.h> for modular stmmac_platform code

Randy Dunlap (1):
      mac80211: fix 90 kernel-doc warnings

Sathya Perla (1):
      Update be2net maintainers' email addresses

Sowmini Varadhan (2):
      net/rds: RDS-TCP: Always create a new rds_sock for an incoming co=
nnection.
      net/rds: RDS-TCP: only initiate reconnect attempt on outgoing TCP=
 socket.

Stefan Wahren (1):
      net: qca_spi: Fix possible race during probe

Tilman Schmidt (1):
      isdn/gigaset: cede maintainership

Tom Herbert (2):
      mpls: Move reserved label definitions
      mpls: Change reserved label names to be consistent with netbsd

Tony Camuso (1):
      netxen_nic: use spin_[un]lock_bh around tx_clean_lock (2)

Toshiaki Makita (2):
      igb: Fix oops on changing number of rings
      igb: Fix NULL assignment to incorrect variable in igb_reset_q_vec=
tor

Varka Bhadram (2):
      mac802154: add description to mac802154 APIs
      cfg802154: pass name_assign_type to rdev_add_virtual_intf()

Vasily Titskiy (1):
      drivers/net/usb: Add support for 'Lenovo OneLink Pro Dock'

Vivien Didelot (1):
      net: dsa: mv88e6xxx: unregister mv88e6352 driver

Vlad Yasevich (2):
      macvlan: Propagate promiscuity setting to lower devices.
      net: core: Correct an over-stringent device loop detection.

WANG Cong (1):
      net_sched: fix a use-after-free in tc_ctl_tfilter()

Wei Yongjun (1):
      mac802154: llsec: fix return value check in llsec_key_alloc()

Yishai Hadas (1):
      net/mlx4_core: Work properly with EQ numbers > 256 in SRIOV

Yuchung Cheng (1):
      tcp: update reordering first before detecting loss

Yuval Mintz (1):
      bnx2x: Fix to prevent inner-reload

shamir rabinovitch (1):
      net/rds: fix unaligned memory access

 MAINTAINERS                                           |  14 +-
 arch/arm/net/bpf_jit_32.c                             |  42 +++++-
 arch/x86/net/bpf_jit_comp.c                           |  28 ++++
 drivers/bluetooth/bt3c_cs.c                           |   3 -
 drivers/bluetooth/btbcm.c                             | 148 ++++++++++=
+----------
 drivers/bluetooth/btbcm.h                             |   6 +
 drivers/bluetooth/btusb.c                             | 403 ++++++++++=
++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/bluetooth/hci_ath.c                           |  98 +++++++++-=
----
 drivers/net/can/xilinx_can.c                          |   7 +-
 drivers/net/dsa/mv88e6xxx.c                           |   3 +
 drivers/net/ethernet/amd/Kconfig                      |   1 +
 drivers/net/ethernet/apm/xgene/Kconfig                |   1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c       |  10 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      |   9 +-
 drivers/net/ethernet/cadence/macb.c                   |  11 +-
 drivers/net/ethernet/intel/e1000e/e1000.h             |   1 +
 drivers/net/ethernet/intel/fm10k/fm10k_main.c         |   4 +-
 drivers/net/ethernet/intel/igb/igb_main.c             |   4 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c     |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_port.c          |   2 +-
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |  14 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c  |   4 +-
 drivers/net/ethernet/qualcomm/qca_spi.c               |   4 +-
 drivers/net/ethernet/realtek/r8169.c                  |   4 +-
 drivers/net/ethernet/smsc/smc91x.c                    |  20 +--
 drivers/net/ethernet/smsc/smsc911x.c                  |  12 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |   1 +
 drivers/net/ethernet/xilinx/ll_temac_main.c           |   4 +-
 drivers/net/hyperv/netvsc.c                           |   9 +-
 drivers/net/ieee802154/at86rf230.c                    | 390 ++++++++++=
+++++++++++++++++++--------------------------
 drivers/net/macvlan.c                                 |  15 +++
 drivers/net/phy/Kconfig                               |   1 +
 drivers/net/phy/mdio-gpio.c                           |   5 +-
 drivers/net/phy/micrel.c                              |   3 +-
 drivers/net/ppp/pppoe.c                               |   4 +
 drivers/net/usb/r8152.c                               |   1 +
 drivers/net/usb/usbnet.c                              |   4 +-
 drivers/net/wireless/ath/ath9k/xmit.c                 |  52 ++++----
 drivers/net/wireless/iwlwifi/iwl-fw-file.h            |   2 +
 drivers/net/wireless/iwlwifi/iwl-trans.h              |  41 ++++--
 drivers/net/wireless/iwlwifi/mvm/d3.c                 |   2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h       |  34 +++++
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h        |  44 +------
 drivers/net/wireless/iwlwifi/mvm/fw-api.h             |  13 --
 drivers/net/wireless/iwlwifi/mvm/fw.c                 |  54 +++-----
 drivers/net/wireless/iwlwifi/mvm/mac80211.c           |  26 +++-
 drivers/net/wireless/iwlwifi/mvm/mvm.h                |   1 -
 drivers/net/wireless/iwlwifi/mvm/ops.c                |  10 ++
 drivers/net/wireless/iwlwifi/mvm/rx.c                 |   5 +
 drivers/net/wireless/iwlwifi/mvm/scan.c               |   2 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c             |  17 +--
 drivers/net/wireless/rtlwifi/usb.c                    |   2 +-
 include/linux/netdevice.h                             |   3 -
 include/linux/tcp.h                                   |   8 ++
 include/net/cfg802154.h                               |   2 +
 include/net/codel.h                                   |  10 +-
 include/net/mac80211.h                                |   2 +
 include/net/mac802154.h                               |  94 ++++++++++=
+++-
 include/net/tcp.h                                     |   7 +-
 include/uapi/linux/inet_diag.h                        |   4 +
 include/uapi/linux/mpls.h                             |  10 ++
 include/uapi/linux/tcp.h                              |   3 +
 net/bluetooth/hci_core.c                              |   3 +-
 net/core/dev.c                                        |   2 +-
 net/core/net_namespace.c                              |   2 +-
 net/core/sock.c                                       |   2 +-
 net/ieee802154/Makefile                               |   4 +-
 net/ieee802154/nl-phy.c                               |   5 +-
 net/ieee802154/nl802154.c                             |   2 +-
 net/ieee802154/rdev-ops.h                             |  85 ++++++++++=
--
 net/ieee802154/trace.c                                |   7 +
 net/ieee802154/trace.h                                | 247 ++++++++++=
+++++++++++++++++++++++++
 net/ipv4/inet_diag.c                                  |   8 +-
 net/ipv4/tcp.c                                        |  28 +++-
 net/ipv4/tcp_dctcp.c                                  |  20 +--
 net/ipv4/tcp_fastopen.c                               |   1 +
 net/ipv4/tcp_illinois.c                               |  21 +--
 net/ipv4/tcp_input.c                                  |  36 ++++--
 net/ipv4/tcp_vegas.c                                  |  19 +--
 net/ipv4/tcp_vegas.h                                  |   3 +-
 net/ipv4/tcp_westwood.c                               |  15 ++-
 net/ipv6/ip6_output.c                                 |  39 ++++--
 net/ipv6/route.c                                      |   5 +-
 net/mac80211/iface.c                                  |  12 +-
 net/mac80211/sta_info.c                               |  19 ++-
 net/mac802154/cfg.c                                   |   9 +-
 net/mac802154/ieee802154_i.h                          |   3 +-
 net/mac802154/iface.c                                 |   5 +-
 net/mac802154/llsec.c                                 |   4 +-
 net/mac802154/main.c                                  |   7 +-
 net/mpls/af_mpls.c                                    |  18 +--
 net/mpls/internal.h                                   |  10 --
 net/netlink/af_netlink.c                              |   1 -
 net/packet/af_packet.c                                |   9 +-
 net/rds/connection.c                                  |  17 ++-
 net/rds/ib_cm.c                                       |  13 +-
 net/rds/tcp_connect.c                                 |   1 +
 net/rds/tcp_listen.c                                  |  46 +++++++
 net/sched/cls_api.c                                   |   7 +-
 net/sched/sch_codel.c                                 |   2 +-
 net/sched/sch_fq_codel.c                              |   2 +-
 net/sched/sch_gred.c                                  |   4 +-
 102 files changed, 1838 insertions(+), 645 deletions(-)
 create mode 100644 net/ieee802154/trace.c
 create mode 100644 net/ieee802154/trace.h
