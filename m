From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 02 Sep 2012 00:34:03 -0400 (EDT)
Message-ID: <20120902.003403.66655294513779453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) NLA_PUT* --> nla_put_* conversion got one case wrong in
   nfnetlink_log, fix from Patrick McHardy.

2) Missed error return check in ipw2100 driver, from Julia Lawall.

3) PMTU updates in ipv4 were setting the expiry time incorrectly, fix
   from Eric Dumazet.

4) SFC driver erroneously reversed src and dst when reporting filters
   via ethtool.

5) Memory leak in CAN protocol and wrong setting of IRQF_SHARED in
   sja1000 can platform driver, from Alexey Khoroshilov and Sven
   Schmitt.

6) Fix multicast traffic scaling regression in ipv4_dst_destroy, only
   take the lock when we really need to.  From Eric Dumazet.

7) Fix non-root process spoofing in netlink, from Pablo Neira Ayuso.

8) CWND reduction in TCP is done incorrectly during non-SACK recovery,
   fix from Yuchung Cheng.

9) Revert netpoll change, and fix what was actually a driver specific
   problem.  From Amerigo Wang.  This should cure bootup hangs with
   netconsole some people reported.

10) Fix xen-netfront invoking __skb_fill_page_desc() with a NULL page
    pointer.  From Ian Campbell.

11) SIP NAT fix for expectiontation creation, from Pablo Neira Ayuso.

12) __ip_rt_update_pmtu() needs RCU locking, from Eric Dumazet.

13) Fix usbnet deadlock on resume, can't use GFP_KERNEL in this
    situation.  From Oliver Neukum.

14) The davinci ethernet driver triggers an OOPS on removal because it
    frees an MDIO object before unregistering it.  Fix from Bin Liu.

Please pull, thanks a lot!

The following changes since commit fea7a08acb13524b47711625eebea40a0ede=
69a0:

  Linux 3.6-rc3 (2012-08-22 13:29:06 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 5002200599429e83fc13e0d9a2d4788b79515b0c=
:

  net: qmi_wwan: add several new Gobi devices (2012-09-01 22:49:34 -040=
0)

----------------------------------------------------------------
Aleksander Morgado (1):
      net: qmi_wwan: new device: Foxconn/Novatel E396

Alexey Khoroshilov (1):
      can: softing: Fix potential memory leak in softing_load_fw()

Amerigo Wang (1):
      netpoll: revert 6bdb7fe3104 and fix be_poll() instead

Ben Hutchings (1):
      sfc: Fix reporting of IPv4 full filters through ethtool

Bin Liu (1):
      net: ethernet: fix kernel OOPS when remove davinci_mdio module

Bj=F8rn Mork (1):
      net: qmi_wwan: add several new Gobi devices

Bruce Allan (1):
      e1000e: DoS while TSO enabled caused by link partner with small M=
SS

Claudiu Manoil (1):
      gianfar: fix default tx vlan offload feature flag

Dan Carpenter (1):
      fddi: 64 bit bug in smt_add_para()

David S. Miller (4):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'fixes-for-3.6' of git://gitorious.org/linux-can/lin=
ux-can
      Merge branch 'sfc-3.6' of git://git.kernel.org/.../bwh/sfc
      Merge branch 'master' of git://1984.lsi.us.es/nf

Eric Dumazet (3):
      ipv4: properly update pmtu
      ipv4: take rt_uncached_lock only if needed
      ipv4: must use rcu protection while calling fib_lookup

=46engguang Wu (1):
      af_packet: match_fanout_group() can be static

=46rancesco Ruggeri (1):
      net: ipv4: ipmr_expire_timer causes crash when removing net names=
pace

Giuseppe CAVALLARO (2):
      stmmac: fix GMAC syn ID
      stmmac: fix a typo in the macro used to mask the mmc irq

Ian Campbell (1):
      xen-netfront: use __pskb_pull_tail to ensure linear area is big e=
nough on RX

Jaccon Bastiaansen (1):
      cs89x0 : packet reception not working

Johannes Berg (2):
      iwlwifi: fix flow handler debug code
      iwlwifi: protect SRAM debugfs

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Julia Lawall (6):
      drivers/net/wireless/ipw2x00/ipw2100.c: introduce missing initial=
ization
      ipvs: fix error return code
      netfilter: ctnetlink: fix error return code in init path
      netfilter: nfnetlink_log: fix error return code in init path
      net: ipv6: fix error return code
      net/xfrm/xfrm_state.c: fix error return code

Merav Sicron (2):
      bnx2x: Move netif_napi_add to the open call
      bnx2x: Correct the ndo_poll_controller call

Oliver Neukum (1):
      usbnet: fix deadlock in resume

Pablo Neira Ayuso (3):
      netlink: fix possible spoofing from non-root processes
      netfilter: nf_nat_sip: fix incorrect handling of EBUSY for RTCP e=
xpectation
      netfilter: nf_conntrack: fix racy timer handling with reliable ev=
ents

Patrick McHardy (1):
      netfilter: nfnetlink_log: fix NLA_PUT macro removal bug

Rayagond Kokatanur (1):
      stmmac: add header inclusion protection

Sven Schmitt (1):
      can: sja1000_platform: fix wrong flag IRQF_SHARED for interrupt s=
haring

Thomas Huehn (1):
      ath5k: fix wrong max power per rate eeprom reads for 802.11a

Thomas Pedersen (1):
      mac80211: fix DS to MBSS address translation

Vladimir Zapolskiy (1):
      brcm80211: smac: set interface down on reset

Yuchung Cheng (1):
      tcp: fix cwnd reduction for non-sack recovery

Yuval Mintz (1):
      bnx2x: fix 57840_MF pci id

xeb@mail.ru (1):
      l2tp: avoid to use synchronize_rcu in tunnel free function

 drivers/net/can/sja1000/sja1000_platform.c            |  4 +++-
 drivers/net/can/softing/softing_fw.c                  |  7 ++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h           |  3 ---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c       |  4 ++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h       |  4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c   |  2 --
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      | 18 ++++++++---=
------
 drivers/net/ethernet/cirrus/cs89x0.c                  | 10 +++++-----
 drivers/net/ethernet/emulex/benet/be_cmds.c           |  6 ++++--
 drivers/net/ethernet/emulex/benet/be_main.c           |  2 ++
 drivers/net/ethernet/freescale/gianfar.c              |  2 +-
 drivers/net/ethernet/intel/e1000e/e1000.h             |  1 +
 drivers/net/ethernet/intel/e1000e/netdev.c            | 48 +++++++++++=
+++++++++++------------------------
 drivers/net/ethernet/sfc/ethtool.c                    |  4 ++--
 drivers/net/ethernet/stmicro/stmmac/common.h          |  5 +++++
 drivers/net/ethernet/stmicro/stmmac/descs.h           |  6 ++++++
 drivers/net/ethernet/stmicro/stmmac/descs_com.h       |  5 +++++
 drivers/net/ethernet/stmicro/stmmac/dwmac100.h        |  5 +++++
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h       |  5 ++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h       |  5 +++++
 drivers/net/ethernet/stmicro/stmmac/mmc.h             |  5 +++++
 drivers/net/ethernet/stmicro/stmmac/mmc_core.c        |  6 +++---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h          |  5 +++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_timer.h    |  4 ++++
 drivers/net/ethernet/ti/davinci_mdio.c                |  4 +++-
 drivers/net/fddi/skfp/pmf.c                           |  2 +-
 drivers/net/usb/qmi_wwan.c                            |  4 ++++
 drivers/net/usb/usbnet.c                              |  2 +-
 drivers/net/wireless/ath/ath5k/eeprom.c               |  2 +-
 drivers/net/wireless/ath/ath5k/eeprom.h               |  1 +
 drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c |  3 +++
 drivers/net/wireless/ipw2x00/ipw2100.c                |  3 ++-
 drivers/net/wireless/iwlwifi/dvm/debugfs.c            |  3 +++
 drivers/net/wireless/iwlwifi/pcie/internal.h          |  2 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c                |  2 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c             | 30 +++++++++++=
++++--------------
 drivers/net/xen-netfront.c                            | 39 ++++++++++-=
--------------------------
 include/linux/pci_ids.h                               |  2 +-
 include/net/netfilter/nf_conntrack_ecache.h           |  1 +
 net/core/netpoll.c                                    | 10 +---------
 net/ipv4/ipmr.c                                       | 14 +++++++++++=
+--
 net/ipv4/netfilter/nf_nat_sip.c                       |  5 ++++-
 net/ipv4/route.c                                      |  6 ++++--
 net/ipv4/tcp_input.c                                  | 15 +++++++----=
----
 net/ipv6/esp6.c                                       |  6 +++---
 net/l2tp/l2tp_core.c                                  |  3 +--
 net/l2tp/l2tp_core.h                                  |  1 +
 net/mac80211/tx.c                                     | 38 +++++++++++=
+++++--------------------
 net/netfilter/ipvs/ip_vs_ctl.c                        |  4 +++-
 net/netfilter/nf_conntrack_core.c                     | 16 +++++++++++=
-----
 net/netfilter/nf_conntrack_netlink.c                  |  3 ++-
 net/netfilter/nfnetlink_log.c                         |  6 ++++--
 net/netlink/af_netlink.c                              |  4 +++-
 net/packet/af_packet.c                                |  2 +-
 net/xfrm/xfrm_state.c                                 |  4 +++-
 55 files changed, 232 insertions(+), 171 deletions(-)
