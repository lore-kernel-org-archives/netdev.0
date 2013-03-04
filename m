From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 04 Mar 2013 14:58:43 -0500 (EST)
Message-ID: <20130304.145843.1020584279448605955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932276Ab3CDT6q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 14:58:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A moderately sized pile of fixes, some specifically for merge window
introduced regressions although we others are for longer standing
items and have been queued up for -stable.

I'm kind of tired of all the RDS protocol bugs over the years, to be
honest, it's way out of proportion to the number of people who
actually use it.

1) Fix missing range initialization in netfilter IPSET, from Jozsef
   Kadlecsik.

2) ieee80211_local->tim_lock needs to use BH disabling, from Johannes
   Berg.

3) Fix DMA syncing in SFC driver, from Ben Hutchings.

4) Fix regression in BOND device MAC address setting, from Jiri Pirko.

5) Missing usb_free_urb in ISDN Hisax driver, from Marina Makienko.

6) Fix UDP checksumming in bnx2x driver for 57710 and 57711 chips, fix
   from Dmitry Kravkov.

7) Missing cfgspace_lock initialization in BCMA driver.

8) Validate parameter size for SCTP assoc stats getsockopt(), from
   Guenter Roeck.

9) Fix SCTP association hangs, from Lee A. Roberts.

10) Fix jumbo frame handling in r8169, from Francois Romieu.

11) Fix phy_device memory leak, from Petr Malat.

12) Omit trailing FCS from frames received in BGMAC driver, from Hauke
    Mehrtens.

13) Missing socket refcount release in L2TP, from Guillaume Nault.

14) sctp_endpoint_init should respect passed in gfp_t, rather than
    use GFP_KERNEL unconditionally.  From Dan Carpenter.

15) Add AISX AX88179 USB driver, from Freddy Xin.

16) Remove MAINTAINERS entries for drivers deleted during the
    merge window, from Cesar Eduardo Barros.

17) RDS protocol can try to allocate huge amounts of memory,
    check that the user's request length makes sense, from Cong
    Wang.

18) SCTP should use the provided KMALLOC_MAX_SIZE instead of it's
    own, bogus, definition.  From Cong Wang.

19) Fix deadlocks in FEC driver by moving TX reclaim into NAPI poll,
    from Frank Li.  Also, fix a build error introduced in the merge
    window.

20) Fix bogus purging of default routes in ipv6, from Lorenzo
    Colitti.

21) Don't double count RTT measurements when we leave the TCP
    receive fast path, from Neal Cardwell.

Please pull, thanks a lot!

The following changes since commit 1cef9350cbee6e3bcf2ff646b8978fbec33f=
8b85:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-0=
2-26 11:44:11 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to aab2b4bf224ef8358d262f95b568b8ad0cecf0a0=
:

  tcp: fix double-counted receiver RTT when leaving receiver fast path =
(2013-03-04 14:12:07 -0500)

----------------------------------------------------------------
Avinash Patil (1):
      mwifiex: correct sleep delay counter

Ben Hutchings (3):
      sfc: Properly sync RX DMA buffer when it is not the last in the p=
age
      sfc: Fix efx_rx_buf_offset() in the presence of swiotlb
      sfc: Detach net device when stopping queues for reconfiguration

Bing Zhao (1):
      libertas: fix crash for SD8688

Bj=F8rn Mork (1):
      net: cdc_ncm: tag Huawei devices (e.g. E5331) with FLAG_WWAN

Cesar Eduardo Barros (3):
      MAINTAINERS: remove 3c505
      MAINTAINERS: remove drivers/net/wan/cycx*
      MAINTAINERS: remove eexpress

Chun-Yeow Yeoh (1):
      mac80211: fix the problem of forwarding from DS to DS in Mesh

Cong Wang (3):
      rds: limit the size allocated by rds_message_alloc()
      sctp: use KMALLOC_MAX_SIZE instead of its own MAX_KMALLOC_SIZE
      rds: simplify a warning message

Dan Carpenter (2):
      irda: small read beyond end of array in debug code
      sctp: use the passed in gfp flags instead GFP_KERNEL

Daniel Mack (1):
      drivers: net: ethernet: cpsw: consider number of slaves in intera=
tion

David S. Miller (4):
      Merge branch 'sfc-3.9' of git://git.kernel.org/.../bwh/sfc
      Merge branch 'master' of git://1984.lsi.us.es/nf
      Merge branch 'sctp'
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless

Dmitry Kravkov (1):
      bnx2x: fix UDP checksum for 57710/57711.

Dor Shaish (1):
      iwlwifi: mvm: Remove testing of static PIC in PhyDB

Eric Dumazet (1):
      tcp: avoid wakeups for pure ACK

=46elix Fietkau (6):
      mac80211: fix idle handling in monitor mode
      mac80211: fix monitor mode channel reporting
      ath9k: fix RSSI dummy marker value
      ath9k_htc: fix signal strength handling issues
      ath9k_hw: improve reset reliability after errors
      rt2x00: error in configurations with mesh support disabled

=46rank Li (2):
      net: fec: put tx to napi poll function to fix dead lock
      net: fec: fix build error in no MXC platform

=46reddy Xin (1):
      ax88179_178a: ASIX AX88179_178A USB 3.0/2.0 to gigabit ethernet a=
dapter driver

Glen Turner (1):
      usb/net/asix_devices: Add USBNET HG20F9 ethernet dongle

Guenter Roeck (1):
      net/sctp: Validate parameter size for SCTP_GET_ASSOC_STATS

Guillaume Nault (1):
      l2tp: Restore socket refcount when sendmsg succeeds

Hauke Mehrtens (2):
      bcma: init spin lock
      bgmac: omit the fcs

Jiri Pirko (1):
      bond: check if slave count is 0 in case when deciding to take sla=
ve's mac

Johannes Berg (6):
      mac80211: fix tim_lock locking
      nl80211: remove radar information
      nl80211: remove TCP WoWLAN information
      iwlwifi: always copy first 16 bytes of commands
      iwlwifi: mvm: fix AP/GO mode station removal
      iwlwifi: fix wakeup status query and packet reporting

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Josh Hunt (1):
      netfilter: ipset: timeout values corrupted on set resize

Jozsef Kadlecsik (3):
      netfilter: ipset: Fix range bug in hash:ip,port,net
      Merge branch 'master' of git://1984.lsi.us.es/nf
      netfilter: ipset: "Directory not empty" error message

Kees Cook (1):
      proc connector: reject unprivileged listener bumps

Lee A. Roberts (4):
      sctp: fix association hangs due to off-by-one errors in sctp_tsnm=
ap_grow()
      sctp: fix association hangs due to reneging packets below the cum=
ulative TSN ACK point
      sctp: fix association hangs due to errors when reneging events fr=
om the ordering queue
      sctp: fix association hangs due to partial delivery errors

Lorenzo Colitti (1):
      net: ipv6: Don't purge default router if accept_ra=3D2

Marina Makienko (1):
      isdn: hisax: add missing usb_free_urb

Neal Cardwell (1):
      tcp: fix double-counted receiver RTT when leaving receiver fast p=
ath

Neil Horman (1):
      ipv[4|6]: correct dropwatch false positive in local_deliver_finis=
h

Petr Malat (1):
      phy: Fix phy_device_free memory leak

Seth Forshee (1):
      mac80211: Ensure off-channel frames don't get queued

Silviu-Mihai Popescu (2):
      caif_dev: fix sparse warnings for caif_flow_cb
      CAIF: fix sparse warning for caif_usb

Vlastimil Kosar (1):
      net/phy: micrel: Disable asymmetric pause for KSZ9021

Yaniv Rosner (3):
      bnx2x: Fix port identification for the 84834
      bnx2x: Fix KR2 link
      bnx2x: Fix KR2 work-around condition

fran=E7ois romieu (1):
      r8169: honor jumbo settings when chipset is requested to start.

 MAINTAINERS                                         |   18 -
 drivers/bcma/driver_pci_host.c                      |    2 +
 drivers/connector/cn_proc.c                         |    8 +
 drivers/isdn/hisax/st5481_usb.c                     |   12 +-
 drivers/net/bonding/bond_main.c                     |    2 +-
 drivers/net/ethernet/broadcom/bgmac.c               |    4 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |    6 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c    |   64 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h    |    3 +-
 drivers/net/ethernet/freescale/fec.c                |   85 ++-
 drivers/net/ethernet/freescale/fec.h                |   18 +-
 drivers/net/ethernet/realtek/r8169.c                |   27 +-
 drivers/net/ethernet/sfc/efx.c                      |   16 +-
 drivers/net/ethernet/sfc/net_driver.h               |    4 +-
 drivers/net/ethernet/sfc/rx.c                       |   25 +-
 drivers/net/ethernet/ti/cpsw.c                      |    2 +-
 drivers/net/phy/micrel.c                            |    3 +-
 drivers/net/phy/phy_device.c                        |   10 +-
 drivers/net/usb/Kconfig                             |   18 +
 drivers/net/usb/Makefile                            |    1 +
 drivers/net/usb/asix_devices.c                      |   31 ++
 drivers/net/usb/ax88179_178a.c                      | 1448 +++++++++++=
+++++++++++++++++++++++++++++++++++++++++
 drivers/net/usb/cdc_ncm.c                           |    8 +
 drivers/net/wireless/ath/ath9k/common.h             |    2 +-
 drivers/net/wireless/ath/ath9k/htc.h                |    1 +
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c       |   18 +-
 drivers/net/wireless/ath/ath9k/hw.c                 |    4 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h         |   10 +-
 drivers/net/wireless/iwlwifi/iwl-phy-db.c           |   16 -
 drivers/net/wireless/iwlwifi/mvm/d3.c               |  104 +++-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c         |   19 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h              |    4 +
 drivers/net/wireless/iwlwifi/pcie/internal.h        |    9 +
 drivers/net/wireless/iwlwifi/pcie/tx.c              |   75 ++-
 drivers/net/wireless/libertas/if_sdio.c             |    6 +-
 drivers/net/wireless/mwifiex/pcie.c                 |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c             |    8 +-
 include/linux/netfilter/ipset/ip_set_ahash.h        |    4 +-
 include/net/tcp.h                                   |    4 +
 net/caif/caif_dev.c                                 |    2 +-
 net/caif/caif_usb.c                                 |    4 +-
 net/ipv4/ip_input.c                                 |    6 +-
 net/ipv4/tcp_input.c                                |    6 +-
 net/ipv6/ip6_input.c                                |    6 +-
 net/ipv6/route.c                                    |    3 +-
 net/irda/iriap.c                                    |    7 +-
 net/l2tp/l2tp_ppp.c                                 |    1 +
 net/mac80211/cfg.c                                  |   12 +-
 net/mac80211/iface.c                                |    2 +-
 net/mac80211/tx.c                                   |   77 ++-
 net/netfilter/ipset/ip_set_core.c                   |    3 +-
 net/rds/message.c                                   |    8 +-
 net/sctp/endpointola.c                              |    2 +-
 net/sctp/socket.c                                   |    6 +-
 net/sctp/ssnmap.c                                   |    8 +-
 net/sctp/tsnmap.c                                   |   13 +-
 net/sctp/ulpqueue.c                                 |   87 +++-
 net/wireless/nl80211.c                              |   61 +--
 59 files changed, 2083 insertions(+), 334 deletions(-)
 create mode 100644 drivers/net/usb/ax88179_178a.c
