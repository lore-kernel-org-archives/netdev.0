From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 03 May 2012 02:59:51 -0400 (EDT)
Message-ID: <20120503.025951.1393913795357644010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


It's the usual jumble of small fixes, mostly in drivers, but a few in
core infrastructure parts and TCP.

1) Transfer padding was wrong for full-speed USB in ASIX driver,
   fix from Ingo van Lil.

2) Propagate the negative packet offset fix into the PowerPC BPF JIT.
   From Jan Seiffert.

3) dl2k driver's private ioctls were letting unprivileged tasks make
   MII writes and other ugly bits like that.  Fix from Jeff Mahoney.

4) Fix TX VLAN and RX packet drops in ucc_geth, from Joakim Tjernlund.

5) OOPS and network namespace fixes in IPVS from Hans Schillstrom and
   Julian Anastasov.

6) Fix races and sleeping in locked context bugs in drop_monitor, from
   Neil Horman.

7) Fix link status indication in smsc95xx driver, from Paolo Pisati.

8) Fix bridge netfilter OOPS, from Peter Huang.

9) L2TP sendmsg can return on error conditions with the socket lock
   held, oops.  Fix from Sasha Levin.

10) udp_diag should return meaningful values for socket memory usage,
    from Shan Wei.

11) Eric Dumazet is so awesome he gets his own section:

	Socket memory cgroup code (I never should have applied those
	patches, grumble...) made erroneous changes to
	sk_sockets_allocated_read_positive().  It was changed to
	use percpu_counter_sum_positive (which requires BH disabling)
	instead of percpu_counter_read_positive (which does not).
	Revert back to avoid crashes and lockdep warnings.

	Adjust the default tcp_adv_win_scale and tcp_rmem[2] values
	to fix throughput regressions.  This is necessary as a result
	of our more precise skb->truesize tracking.

	Fix SKB leak in netem packet scheduler.

12) New device IDs for various bluetooth devices, from Manoj Iyer,
    AceLan Kao, and Steven Harms.

13) Fix command completion race in ipw2200, from Stanislav Yakovlev.

14) Fix rtlwifi oops on unload, from Larry Finger.

15) Fix hard_mtu when adjusting hard_header_len in smsc95xx driver. From
    Stephane Fillod.

16) ehea driver registers it's IRQ before all the necessary state is
    setup, resulting in crashes.  Fix from Thadeu Lima de Souza
    Cascardo.

17) Fix PHY connection failures in davinci_emac driver, from Anatolij
    Gustschin.

18) Missing break; in switch statement in bluetooth's
    hci_cmd_complete_evt().  Fix from Szymon Janc.

19) Fix queue programming in iwlwifi, from Johannes Berg.

20) Interrupt throttling defaults not being actually programmed
    into the hardware, fix from Jeff Kirsher and Ying Cai.

21) TLAN driver SKB encoding in descriptor busted on 64-bit, fix
    from Benjamin Poirier.

22) Fix blind status block RX producer pointer deref in TG3 driver,
    from Matt Carlson.

23) Promisc and multicast are busted on ehea, fixes from Thadeu Lima
    de Souza Cascardo.

24) Fix crashes in 6lowpan, from Alexander Smirnov.

25) tcp_complete_cwr() needs to be careful to not rewind the CWND to
    ssthresh if ssthresh has the "infinite" value.  Fix from Yuchung
    Cheng.

Please pull, thanks a lot.

The following changes since commit 4d634ca35a8b38530b134ae92bc9e3cc9c23c030:

  Merge branch 'rc-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/mmarek/kbuild (2012-04-23 19:45:19 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 5a8887d39e1ba5ee2d4ccb94b14d6f2dce5ddfca:

  sungem: Fix WakeOnLan (2012-05-03 01:42:55 -0400)

----------------------------------------------------------------
AceLan Kao (2):
      Bluetooth: Add support for Atheros [13d3:3362]
      Bluetooth: Add support for AR3012 [0cf3:e004]

Alexander Duyck (1):
      ixgbe: Fix a memory leak in IEEE DCB

Anatolij Gustschin (1):
      net/davinci_emac: fix failing PHY connect attempts

Benjamin Poirier (1):
      tlan: add cast needed for proper 64 bit operation

David S. Miller (4):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net
      Merge branch 'master' of git://1984.lsi.us.es/net
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net

Eldad Zack (1):
      brcmsmac: "INTERMEDIATE but not AMPDU" only when tracing

Eliad Peller (1):
      mac80211: call ieee80211_mgd_stop() on interface stop

Eric Dumazet (4):
      net: fix sk_sockets_allocated_read_positive
      net: fix two typos in skbuff.h
      netem: fix possible skb leak
      tcp: change tcp_adv_win_scale and tcp_rmem[2]

Felix Fietkau (1):
      mac80211: fix AP mode EAP tx for VLAN stations

Franky Lin (2):
      brcm80211: fmac: fix SDIO function 0 register r/w issue
      brcm80211: fmac: fix missing completion events issue

Gabor Juhos (2):
      ath9k: add an extra boolean parameter to ath9k_hw_apply_txpower
      ath9k: fix tx power settings for AR9287

Gerard Lledo (1):
      sungem: Fix WakeOnLan

Grazvydas Ignotas (2):
      wl1251: fix crash on remove due to premature kfree
      wl1251: fix crash on remove due to leftover work item

Hans Schillstrom (3):
      ipvs: null check of net->ipvs in lblc(r) shedulers
      ipvs: take care of return value from protocol init_netns
      ipvs: kernel oops - do_ip_vs_get_ctl

Ingo van Lil (1):
      asix: Fix tx transfer padding for full-speed USB

Jan Seiffert (1):
      bpf jit: Let the powerpc jit handle negative offsets

Jeff Kirsher (1):
      e1000e: Fix default interrupt throttle rate not set in NIC HW

Jeff Mahoney (1):
      dl2k: Clean up rio_ioctl

Joakim Tjernlund (2):
      net: ucc_geth, increase no. of HW RX descriptors
      ucc_geth: Add 16 bytes to max TX frame for VLANs

Johannes Berg (1):
      iwlwifi: fix hardware queue programming

John W. Linville (3):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Jonathan Bither (1):
      ath5k: add missing iounmap to AHB probe removal

Julian Anastasov (3):
      ipvs: fix crash in ip_vs_control_net_cleanup on unload
      ipvs: add check in ftp for initialized core
      ipvs: reset ipvs pointer in netns

Larry Finger (1):
      rtlwifi: Fix oops on unload

Manoj Iyer (1):
      Bluetooth: btusb: Add vendor specific ID (0489 e042) for BCM20702A0

Matt Carlson (1):
      tg3: Avoid panic from reserved statblk field access

Meenakshi Venkataraman (1):
      iwlwifi: use correct released ucode version

Neal Cardwell (1):
      tcp: clean up use of jiffies in tcp_rcv_rtt_measure()

Neil Horman (3):
      drop_monitor: fix sleeping in invalid context warning
      drop_monitor: Make updating data->skb smp safe
      drop_monitor: prevent init path from scheduling on the wrong cpu

Pablo Neira Ayuso (1):
      netfilter: xt_CT: fix wrong checking in the timeout assignment path

Paolo Pisati (1):
      smsc95xx: mark link down on startup and let PHY interrupt deal with carrier changes

Peter Huang (Peng) (1):
      set fake_rtable's dst to NULL to avoid kernel Oops

Prasanna S Panchamukhi (1):
      e1000e: MSI interrupt test failed, using legacy interrupt

Roland Dreier (1):
      cxgb3: Don't call cxgb_vlan_mode until q locks are initialized

Samuel Liao (1):
      igbvf: fix the bug when initializing the igbvf

Sasha Levin (2):
      ipvs: Verify that IP_VS protocol has been registered
      net: l2tp: unlock socket lock before returning from l2tp_ip_sendmsg

Seth Forshee (1):
      b43: only reload config after successful initialization

Shan Wei (1):
      udp_diag: implement idiag_get_info for udp/udplite to get queue information

Stanislav Yakovlev (1):
      ipw2200: Fix race condition in the command completion acknowledge

Stanislaw Gruszka (1):
      iwlwifi: do not nulify ctx->vif on reset

Stefan Raspl (1):
      qeth: Use blkt defaults for OSA Express 4

Stephane Fillod (1):
      net: usb: smsc95xx: fix mtu

Steve Glendinning (7):
      smsc75xx: mark link down on startup and let PHY interrupt deal with carrier changes
      smsc75xx: fix mdio reads and writes
      smsc75xx: add more information to register io failure warnings
      smsc75xx: fix phy init reset loop
      smsc75xx: fix phy interrupt acknowledge
      smsc75xx: declare smsc75xx's MII as GMII capable
      smsc75xx: enable mac to detect speed/duplex from phy

Steven Harms (1):
      Add Foxconn / Hon Hai IDs for btusb module

Szymon Janc (1):
      Bluetooth: Fix missing break in hci_cmd_complete_evt

Thadeu Lima de Souza Cascardo (3):
      ehea: only register irq after setting up ports
      ehea: fix allmulticast support
      ehea: fix promiscuous mode

Ursula Braun (1):
      qeth: allow change of blkt default values

Vishal Agarwal (2):
      Bluetooth: hci_persistent_key should return bool
      Bluetooth: Temporary keys should be retained during connection

Vlad Yasevich (1):
      MAINTAINERS: update sctp maintainer address

Wey-Yi Guy (1):
      iwlwifi: use 6000G2B for 6030 device series

Yi Zou (1):
      ixgbe: fix calling skb_put on nonlinear skb assertion bug

Yuchung Cheng (1):
      tcp: fix infinite cwnd in tcp_complete_cwr()

alex.bluesman.smirnov@gmail.com (3):
      6lowpan: fix segmentation fault caused by mlme request
      6lowpan: clean up fragments list if module unloaded
      6lowpan: add missing spin_lock_init()

stephen hemminger (2):
      sky2: propogate rx hash when packet is copied
      sky2: fix receive length error in mixed non-VLAN/VLAN traffic

tom.leiming@gmail.com (2):
      usbnet: fix leak of transfer buffer of dev->interrupt
      usbnet: fix failure handling in usbnet_probe

 Documentation/networking/ip-sysctl.txt                 |    4 +-
 MAINTAINERS                                            |    4 +-
 arch/powerpc/net/bpf_jit.h                             |    8 +++-
 arch/powerpc/net/bpf_jit_64.S                          |  108 +++++++++++++++++++++++++++++++++++++++------
 arch/powerpc/net/bpf_jit_comp.c                        |   26 ++++-------
 drivers/bluetooth/ath3k.c                              |    4 ++
 drivers/bluetooth/btusb.c                              |    6 +++
 drivers/net/ethernet/broadcom/tg3.c                    |   18 +++++++-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c        |   92 +++++++++++++++++++-------------------
 drivers/net/ethernet/dlink/dl2k.c                      |   52 ++++------------------
 drivers/net/ethernet/dlink/dl2k.h                      |    7 ---
 drivers/net/ethernet/freescale/ucc_geth.c              |    6 +--
 drivers/net/ethernet/freescale/ucc_geth.h              |    2 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c              |   60 ++++++++++++++-----------
 drivers/net/ethernet/ibm/ehea/ehea_phyp.h              |    2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c             |    2 +-
 drivers/net/ethernet/intel/e1000e/param.c              |   99 ++++++++++++++++++++++-------------------
 drivers/net/ethernet/intel/igbvf/netdev.c              |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c          |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c          |    9 ++--
 drivers/net/ethernet/marvell/sky2.c                    |   31 ++++++++-----
 drivers/net/ethernet/marvell/sky2.h                    |    1 -
 drivers/net/ethernet/sun/sungem.c                      |    2 +-
 drivers/net/ethernet/ti/davinci_emac.c                 |    2 +-
 drivers/net/ethernet/ti/tlan.c                         |    2 +-
 drivers/net/usb/asix.c                                 |    4 +-
 drivers/net/usb/smsc75xx.c                             |   35 ++++++++++-----
 drivers/net/usb/smsc95xx.c                             |    3 +-
 drivers/net/usb/usbnet.c                               |    5 ++-
 drivers/net/wireless/ath/ath5k/ahb.c                   |    1 +
 drivers/net/wireless/ath/ath9k/ar5008_phy.c            |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c          |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c            |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c           |    2 +
 drivers/net/wireless/ath/ath9k/hw.c                    |    9 ++--
 drivers/net/wireless/ath/ath9k/hw.h                    |    3 +-
 drivers/net/wireless/b43/main.c                        |   10 ++++-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |    8 +++-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c     |   63 +++++++++++++++++++++-----
 drivers/net/wireless/brcm80211/brcmsmac/main.c         |    3 +-
 drivers/net/wireless/ipw2x00/ipw2200.c                 |   13 +++++-
 drivers/net/wireless/iwlwifi/iwl-1000.c                |    8 ++--
 drivers/net/wireless/iwlwifi/iwl-2000.c                |   16 +++----
 drivers/net/wireless/iwlwifi/iwl-5000.c                |   11 ++++-
 drivers/net/wireless/iwlwifi/iwl-6000.c                |   10 +++--
 drivers/net/wireless/iwlwifi/iwl-agn.c                 |    3 --
 drivers/net/wireless/iwlwifi/iwl-fh.h                  |   24 +++++++---
 drivers/net/wireless/iwlwifi/iwl-mac80211.c            |   10 ++++-
 drivers/net/wireless/iwlwifi/iwl-prph.h                |   27 ++++++++++--
 drivers/net/wireless/rtlwifi/pci.c                     |    1 +
 drivers/net/wireless/wl1251/main.c                     |    1 +
 drivers/net/wireless/wl1251/sdio.c                     |    2 +-
 drivers/s390/net/qeth_core_main.c                      |    6 ++-
 include/linux/netfilter_bridge.h                       |    9 ++++
 include/linux/skbuff.h                                 |    4 +-
 include/net/bluetooth/hci_core.h                       |    3 +-
 include/net/dst.h                                      |    1 +
 include/net/ip_vs.h                                    |    4 +-
 include/net/sock.h                                     |    4 +-
 net/bluetooth/hci_core.c                               |   27 ++++++------
 net/bluetooth/hci_event.c                              |    3 ++
 net/bluetooth/mgmt.c                                   |    2 +-
 net/bridge/br_forward.c                                |    1 +
 net/bridge/br_netfilter.c                              |    8 +---
 net/core/drop_monitor.c                                |   88 ++++++++++++++++++++++++++----------
 net/ieee802154/6lowpan.c                               |   40 ++++++++++++++++-
 net/ipv4/inet_diag.c                                   |    2 +-
 net/ipv4/tcp.c                                         |    9 ++--
 net/ipv4/tcp_input.c                                   |   13 +++---
 net/ipv4/udp_diag.c                                    |    9 ++++
 net/l2tp/l2tp_ip.c                                     |    3 +-
 net/mac80211/ieee80211_i.h                             |    2 +-
 net/mac80211/iface.c                                   |    4 +-
 net/mac80211/mlme.c                                    |    2 +-
 net/mac80211/tx.c                                      |    3 +-
 net/netfilter/ipvs/ip_vs_core.c                        |   11 +++++
 net/netfilter/ipvs/ip_vs_ctl.c                         |   56 +++++++++++++----------
 net/netfilter/ipvs/ip_vs_ftp.c                         |    2 +
 net/netfilter/ipvs/ip_vs_lblc.c                        |    3 ++
 net/netfilter/ipvs/ip_vs_lblcr.c                       |    3 ++
 net/netfilter/ipvs/ip_vs_proto.c                       |   38 +++++++++++-----
 net/netfilter/ipvs/ip_vs_proto_sctp.c                  |    5 ++-
 net/netfilter/ipvs/ip_vs_proto_tcp.c                   |    5 ++-
 net/netfilter/ipvs/ip_vs_proto_udp.c                   |    5 ++-
 net/netfilter/xt_CT.c                                  |    2 +-
 net/sched/sch_netem.c                                  |    6 +--
 86 files changed, 795 insertions(+), 418 deletions(-)
