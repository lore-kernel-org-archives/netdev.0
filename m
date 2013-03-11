From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 11 Mar 2013 07:43:13 -0400 (EDT)
Message-ID: <20130311.074313.2173151576767360351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Missing cancel of work items in mac80211 MLME, from
   Ben Greear.

2) Fix DMA mapping handling in iwlwifi by using coherent DMA for
   command headers, from Johannes Berg.

3) Decrease the amount of pressure on the page allocator by
   using order 1 pages less in iwlwifi, from Emmanuel Grumbach.

4) Fix mesh PS broadcast OOPS in mac80211, from Marco Porsch.

5) Don't forget to recalculate idle state in mac80211 monitor
   interface, from Felix Fietkau.

6) Fix varargs in netfilter conntrack handler, from Joe Perches.

7) Need to reset entire chip when command queue fills up in
   iwlwifi, from Emmanuel Grumbach.

8) The TX antenna value must be valid when calibrations are
   performmed in iwlwifi, fix from Dor Shaish.

9) Don't generate netfilter audit log entries when audit is disabled,
   from Gao Feng.

10) Deal with DMA unit hang on e1000e during power state transitions,
    from Bruce Allan.

11) Remove BUILD_BUG_ON check from igb driver, from Alexander
    Duyck.

12) Fix lockdep warning on i2c handling of igb driver, from Carolyn
    Wyborny.

13) Fix several TTY handling issues in IRDA ircomm tty driver, from
    Peter Hurley.

14) Several QFQ packet scheduler fixes from Paolo Valente.

15) When VXLAN encapsulates on transmit, we have to reset the
    netfilter state.  From Zang MingJie.

16) Fix jiffie check in net_rx_action() so that we really cap the
    processing at 2HZ.  From Eric Dumazet.

17) Fix erroneous trigger of IP option space exhaustion, when
    routers are pre-specified and we are looking to see if we
    can insert a timestamp, we will have the space.  From David
    Ward.

18) Fix various issues in benet driver wrt. waiting for firmware to
    finish POST after resets or errors.  From Gavin Shan and Sathya
    Perla.

19) Fix TX locking in SFC driver, from Ben Hutchings.

20) Like the VXLAN fix above, when we encap in a TUN device we have
    to reset the netfilter state.  This should fix several strange
    crashes reported by Dave Jones and others.  From Eric Dumazet.

21) Don't forget to clean up MAC address resources when shutting down
    a port in mlx4 driver, from Yan Burman.

22) Fix divide by zero in vmxnet3 driver, from Bhavesh Davda.

23) Fix device statistic regression in tg3 when the driver is
    using phylib, from Nithin Sujir.

24) Fix info leak in several netlink handlers, from Mathias
    Krause.

Please pull, thanks a lot!

The following changes since commit 9f225788cc047fb7c2ef2326eb4f86dee890e2ef:

  Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/git/benh/powerpc (2013-03-05 18:56:22 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 9026c4927254f5bea695cc3ef2e255280e6a3011:

  6lowpan: Fix endianness issue in is_addr_link_local(). (2013-03-10 16:49:35 -0400)

----------------------------------------------------------------
Alexander Duyck (1):
      igb: Drop BUILD_BUG_ON check from igb_build_rx_buffer

Amir Vadai (1):
      net/mlx4_en: Disable RFS when running in SRIOV mode

Ben Greear (2):
      mac80211: stop timers before canceling work items
      mac80211: Fix crash due to un-canceled work-items

Ben Hutchings (2):
      sfc: Disable soft interrupt handling during efx_device_detach_sync()
      sfc: Correct efx_rx_buffer::page_offset when EFX_PAGE_IP_ALIGN != 0

Bhavesh Davda (1):
      vmxnet3: prevent div-by-zero panic when ring resizing uninitialized dev

Bruce Allan (1):
      e1000e: workaround DMA unit hang on I218

Carolyn Wyborny (2):
      igb: Fix link setup for I210 devices
      igb: Fix for lockdep issue in igb_get_i2c_client

Chen Gang (2):
      net/rds: zero last byte for strncpy
      drivers/isdn: checkng length to be sure not memory overflow

Christoph Paasch (1):
      Fix: sparse warning in inet_csk_prepare_forced_close

Cong Wang (1):
      bridge: add missing vid to br_mdb_get()

Cristian Bercaru (1):
      bridging: fix rx_handlers return code

David Oostdyk (1):
      rrunner.c: fix possible memory leak in rr_init_one()

David S. Miller (6):
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net into intel
      Merge branch 'sfc-3.9' of git://git.kernel.org/.../bwh/sfc
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless
      Merge branch 'intel'
      Merge branch 'master' of git://1984.lsi.us.es/nf
      Merge branch 'mlx4'

David Ward (1):
      net/ipv4: Timestamp option cannot overflow with prespecified addresses

Dor Shaish (3):
      iwlwifi: mvm: Set valid TX antennas value before calib request
      iwlwifi: mvm: Take the phy_cfg from the TLV value
      iwlwifi: mvm: Remove overriding calibrations for the 7000 family

Emmanuel Grumbach (5):
      iwlwifi: disable 8K A-MSDU by default
      iwlwifi: mvm: restart the NIC of the cmd queue gets full
      iwlwifi: mvm: ignore STOP_AGG when restarting
      iwlwifi: mvm: update the rssi calculation
      iwlwifi: mvm: don't warn on normal BAR sending

Eric Dumazet (2):
      net: reduce net_rx_action() latency to 2 HZ
      tun: add a missing nf_reset() in tun_net_xmit()

Felix Fietkau (1):
      mac80211: another fix for idle handling in monitor mode

Gao feng (1):
      netfilter: xt_AUDIT: only generate audit log when audit enabled

Gavin Shan (1):
      benet: Wait f/w POST until timeout

Hannes Frederic Sowa (1):
      ipv6: stop multicast forwarding to process interface scoped addresses

Jack Morgenstein (3):
      net/mlx4_core: Disable mlx4_QP_ATTACH calls from guests if the host uses flow steering
      net/mlx4_core: Turn off device-managed FS bit in dev-cap wrapper if DMFS is not enabled
      net/mlx4_core: Fix endianness bug in set_param_l

Jason Wang (1):
      net: docs: document multiqueue tuntap API

Joe Perches (1):
      netfilter: nf_ct_helper: Fix logging for dropped packets

Johannes Berg (7):
      nl80211: remove channel width and extended capa advertising
      mac80211: really fix monitor mode channel reporting
      iwlwifi: don't map complete commands bidirectionally
      iwlwifi: rename IWL_MAX_CMD_TFDS to IWL_MAX_CMD_TBS_PER_TFD
      iwlwifi: use coherent DMA memory for command header
      nl80211: increase wiphy dump size dynamically
      mac80211: fix VHT MCS calculation

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Junwei Zhang (1):
      afkey: fix a typo

Konstantin Khlebnikov (3):
      e1000e: fix pci-device enable-counter balance
      e1000e: fix runtime power management transitions
      e1000e: fix accessing to suspended device

Marco Porsch (1):
      mac80211: fix oops on mesh PS broadcast forwarding

Mathias Krause (3):
      bridge: fix mdb info leaks
      rtnl: fix info leak on RTM_GETLINK request for VF devices
      dcbnl: fix various netlink info leaks

Nithin Sujir (1):
      tg3: Update link_up flag for phylib devices

Paolo Valente (6):
      pkt_sched: sch_qfq: properly cap timestamps in charge_actual_service
      pkt_sched: sch_qfq: fix the update of eligible-group sets
      pkt_sched: sch_qfq: serve activated aggregates immediately if the scheduler is empty
      pkt_sched: sch_qfq: prevent budget from wrapping around after a dequeue
      pkt_sched: sch_qfq: do not allow virtual time to jump if an aggregate is in service
      pkt_sched: sch_qfq: remove a useless invocation of qfq_update_eligible

Paul Bolle (1):
      netfilter: nfnetlink: silence warning if CONFIG_PROVE_RCU isn't set

Paul Moore (2):
      netlabel: correctly list all the static label mappings
      netlabel: fix build problems when CONFIG_IPV6=n

Peter Hurley (4):
      net/irda: Fix port open counts
      net/irda: Hold port lock while bumping blocked_open
      net/irda: Use barrier to set task state
      net/irda: Raise dtr in non-blocking open

Phil Sutter (1):
      mv643xx_eth: fix for disabled autoneg

Randy Dunlap (1):
      net: fix new kernel-doc warnings in net core

Sathya Perla (1):
      be2net: use CSR-BAR SEMAPHORE reg for BE2/BE3

Sony Chacko (1):
      MAINTAINERS: Update qlcnic maintainers list

Veaceslav Falico (1):
      bonding: fire NETDEV_RELEASE event only on 0 slaves

Vlad Yasevich (2):
      team: unsyc the devices addresses when port is removed
      macvlan: Set IFF_UNICAST_FLT flag to prevent unnecessary promisc mode.

YOSHIFUJI Hideaki / 吉藤英明 (1):
      6lowpan: Fix endianness issue in is_addr_link_local().

Yan Burman (2):
      net/mlx4_en: Fix race when setting the device MAC address
      net/mlx4_en: Cleanup MAC resources on module unload or port stop

Yaniv Rosner (2):
      bnx2x: Fix intermittent long KR2 link up time
      bnx2x: Fix SFP+ misconfiguration in iSCSI boot scenario

Zang MingJie (2):
      reset nf before xmit vxlan encapsulated packet
      vxlan: fix oops when delete netns containing vxlan

 Documentation/networking/tuntap.txt                   |   77 +++++++++
 MAINTAINERS                                           |    2 +
 drivers/isdn/i4l/isdn_tty.c                           |    4 +-
 drivers/net/bonding/bond_main.c                       |    5 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c      |   17 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h      |    4 +-
 drivers/net/ethernet/broadcom/tg3.c                   |   14 +-
 drivers/net/ethernet/emulex/benet/be.h                |    1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c           |   36 ++--
 drivers/net/ethernet/emulex/benet/be_hw.h             |    4 +-
 drivers/net/ethernet/emulex/benet/be_main.c           |   10 ++
 drivers/net/ethernet/intel/e1000e/ethtool.c           |   13 ++
 drivers/net/ethernet/intel/e1000e/ich8lan.c           |   71 +++++++-
 drivers/net/ethernet/intel/e1000e/ich8lan.h           |    2 +
 drivers/net/ethernet/intel/e1000e/netdev.c            |   82 +++------
 drivers/net/ethernet/intel/e1000e/regs.h              |    1 +
 drivers/net/ethernet/intel/igb/e1000_82575.c          |   11 +-
 drivers/net/ethernet/intel/igb/igb.h                  |    2 +-
 drivers/net/ethernet/intel/igb/igb_hwmon.c            |   14 ++
 drivers/net/ethernet/intel/igb/igb_main.c             |   76 +--------
 drivers/net/ethernet/marvell/mv643xx_eth.c            |   55 +++++-
 drivers/net/ethernet/mellanox/mlx4/cq.c               |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |   86 +++++-----
 drivers/net/ethernet/mellanox/mlx4/fw.c               |    8 +
 drivers/net/ethernet/mellanox/mlx4/main.c             |    2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h             |    2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h          |    1 -
 drivers/net/ethernet/mellanox/mlx4/mr.c               |   10 +-
 drivers/net/ethernet/mellanox/mlx4/pd.c               |    2 +-
 drivers/net/ethernet/mellanox/mlx4/port.c             |    8 +-
 drivers/net/ethernet/mellanox/mlx4/qp.c               |    8 +-
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |    3 +
 drivers/net/ethernet/mellanox/mlx4/srq.c              |    2 +-
 drivers/net/ethernet/sfc/efx.h                        |    4 +-
 drivers/net/ethernet/sfc/rx.c                         |    2 +-
 drivers/net/hippi/rrunner.c                           |    3 +
 drivers/net/macvlan.c                                 |    1 +
 drivers/net/team/team.c                               |    2 +
 drivers/net/tun.c                                     |    2 +
 drivers/net/vmxnet3/vmxnet3_drv.c                     |    1 +
 drivers/net/vmxnet3/vmxnet3_ethtool.c                 |    6 +
 drivers/net/vmxnet3/vmxnet3_int.h                     |    4 +-
 drivers/net/vxlan.c                                   |   10 ++
 drivers/net/wireless/iwlwifi/dvm/sta.c                |    2 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h           |    2 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c                |    3 +-
 drivers/net/wireless/iwlwifi/iwl-modparams.h          |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h              |   20 +--
 drivers/net/wireless/iwlwifi/mvm/fw-api.h             |   18 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c                 |  133 +--------------
 drivers/net/wireless/iwlwifi/mvm/mvm.h                |    3 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c                |   18 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c                 |   37 +++--
 drivers/net/wireless/iwlwifi/mvm/sta.c                |   10 ++
 drivers/net/wireless/iwlwifi/mvm/tx.c                 |    6 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h          |   34 +++-
 drivers/net/wireless/iwlwifi/pcie/rx.c                |   14 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c                |  266 ++++++++++++++----------------
 net/bridge/br_device.c                                |    2 +-
 net/bridge/br_input.c                                 |    2 +-
 net/bridge/br_mdb.c                                   |    4 +
 net/bridge/br_multicast.c                             |    3 +-
 net/bridge/br_private.h                               |    4 +-
 net/core/dev.c                                        |    5 +-
 net/core/rtnetlink.c                                  |    1 +
 net/dcb/dcbnl.c                                       |    8 +
 net/ieee802154/6lowpan.h                              |    2 +-
 net/ipv4/inet_connection_sock.c                       |    1 +
 net/ipv4/ip_options.c                                 |    2 +-
 net/ipv6/ip6_input.c                                  |    3 +-
 net/irda/ircomm/ircomm_tty.c                          |   29 ++--
 net/key/af_key.c                                      |    8 +-
 net/mac80211/cfg.c                                    |   21 ++-
 net/mac80211/iface.c                                  |    6 +
 net/mac80211/mlme.c                                   |   28 +++-
 net/mac80211/tx.c                                     |    3 +-
 net/netfilter/nf_conntrack_helper.c                   |   11 +-
 net/netfilter/nfnetlink.c                             |    7 +-
 net/netfilter/xt_AUDIT.c                              |    3 +
 net/netlabel/netlabel_unlabeled.c                     |   27 ++-
 net/rds/stats.c                                       |    1 +
 net/sched/sch_qfq.c                                   |   66 +++++---
 net/wireless/core.c                                   |    3 +-
 net/wireless/nl80211.c                                |   51 +++---
 84 files changed, 843 insertions(+), 696 deletions(-)
