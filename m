From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 14 Jan 2015 17:12:54 -0500 (EST)
Message-ID: <20150114.171254.46734872853630430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Don't use uninitialized data in IPVS, from Dan Carpenter.

2) conntrack race fixes from Pablo Neira Ayuso.

3) Fix TX hangs with i40e, from Jesse Brandeburg.

4) Fix budget return from poll calls in dnet and alx, from Eric Dumazet.

5) Fix bugus "if (unlikely(x) < 0)" test in AF_PACKET, from Christoph	
   Jaeger.

6) Fix bug introduced by conversion to list_head in TIPC retransmit
   code, from Jon Paul Maloy.

7) Don't use GFP_NOIO under spinlock in USB kaweth driver, from Alexey
   Khoroshilov.

8) Fix bridge build with INET disabled, from Arnd Bergmann.

9) Fix netlink array overrun for PROBE attributes in openvswitch,
   from Thomas Graf.

10) Don't hold spinlock across synchronize_irq() in tg3 driver, from
    Prashant Sreedharan.

Please pull, thanks a lot.

The following changes since commit bdec41963890f8ed9ad89f8b418959ab3cdc2aa3:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-01-06 17:48:14 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to c637dbcedf31ce1dd813a461de406f45aa7a3d38:

  Merge branch 'tg3-net' (2015-01-14 17:05:55 -0500)

----------------------------------------------------------------

Alexandre Belloni (1):
      net/at91_ether: prepare and unprepare clock

Alexey Khoroshilov (1):
      usb/kaweth: use GFP_ATOMIC under spin_lock in usb_start_wait_urb()

Ani Sinha (1):
      update ip-sysctl.txt documentation (v2)

Anjali Singhai (2):
      i40e: Fix Rx checksum error counter
      i40e: Fix bug with TCP over IPv6 over VXLAN

Arik Nemtsov (1):
      iwlwifi: pcie: correctly define 7265-D cfg

Arnd Bergmann (1):
      bridge: only provide proxy ARP when CONFIG_INET is enabled

B Viswanath (1):
      net: Corrected the comment describing the ndo operations to reflect the actual prototype for couple of operations

Benjamin Poirier (1):
      netdevice: Add missing parentheses in macro

Christoph Jaeger (1):
      packet: bail out of packet_snd() if L2 header creation fails

Dan Carpenter (1):
      ipvs: uninitialized data with IP_VS_IPV6

David S. Miller (4):
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net
      Merge git://git.kernel.org/.../pablo/nf
      Merge tag 'wireless-drivers-for-davem-2015-01-09' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge branch 'tg3-net'

David Spinadel (2):
      iwlwifi: mvm: add a flag to enable match found notification
      iwlwifi: mvm: scan dwell time corrections

David Vrabel (1):
      xen-netfront: use different locks for Rx and Tx stats

Emmanuel Grumbach (2):
      iwlwifi: 7000: fix reported firmware name for 7265D
      iwlwifi: bump firmware API for mvm devices to 12

Eric Dumazet (2):
      net: dnet: fix dnet_poll()
      alx: fix alx_poll()

Eyal Shapira (2):
      iwlwifi: mvm: fix Rx with both chains
      iwlwifi: mvm: fix out of bounds access to tid_to_mac80211_ac

Giel van Schijndel (1):
      isdn: fix NUL (\0 or \x00) specification in string

Hariprasad Shenai (2):
      cxgb4vf: Initialize mdio_addr before using it
      cxgb4vf: Fix queue allocation for 40G adapter

Hubert Feurstein (1):
      net: fec: fix NULL pointer dereference in fec_enet_timeout_work

Jean-Francois Remy (1):
      neighbour: fix base_reachable_time(_ms) not effective immediatly when changed

Jesse Brandeburg (1):
      i40e: fix un-necessary Tx hangs

Jiri Pirko (1):
      team: avoid possible underflow of count_pending value for notify_peers and mcast_rejoin

Jon Paul Maloy (1):
      tipc: fix bug in broadcast retransmit code

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-01-05' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Larry Finger (1):
      rtlwifi: Fix error when accessing unmapped memory in skb

Mugunthan V N (1):
      drivers: net: cpsw: fix multicast flush in dual emac mode

Nobuhiro Iwamatsu (2):
      sh-eth: Set fdr_value of R-Car SoCs
      sh_eth: Fix access to TRSCER register

Pablo Neira Ayuso (5):
      Merge tag 'ipvs2-for-v3.19' of https://git.kernel.org/.../horms/ipvs-next into ipvs-next
      netfilter: conntrack: fix race between confirmation and flush
      netfilter: nfnetlink: validate nfnetlink header from batch
      netfilter: nfnetlink: relax strict multicast group check from netlink_bind
      netfilter: nf_tables: fix flush ruleset chain dependencies

Prashant Sreedharan (3):
      tg3: tg3_timer() should grab tp->lock before checking for tp->irq_sync
      tg3: tg3_reset_task() needs to use rtnl_lock to synchronize
      tg3: Release tp->lock before invoking synchronize_irq()

Stefan Agner (1):
      net: fec: fix MDIO bus assignement for dual fec SoC's

Thomas Falcon (1):
      MAINTAINERS: add me as ibmveth maintainer

Thomas Graf (1):
      openvswitch: packet messages need their own probe attribtue

Vasu Dev (1):
      i40e: adds FCoE configure option

leroy christophe (1):
      netfilter: nf_tables: fix port natting in little endian archs

 Documentation/networking/ip-sysctl.txt              |   2 ++
 MAINTAINERS                                         |   2 +-
 arch/arm/boot/dts/imx6sx-sdb.dts                    |  15 ++++++++++
 arch/arm/boot/dts/vf610-twr.dts                     |  15 ++++++++++
 drivers/isdn/hardware/eicon/message.c               |   2 +-
 drivers/net/ethernet/atheros/alx/main.c             |  24 ++++++++--------
 drivers/net/ethernet/broadcom/tg3.c                 |  23 +++++++++++++--
 drivers/net/ethernet/cadence/at91_ether.c           |  10 +++----
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c |   2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c      |   2 ++
 drivers/net/ethernet/dnet.c                         |  18 ++++--------
 drivers/net/ethernet/freescale/fec.h                |   2 ++
 drivers/net/ethernet/freescale/fec_main.c           |  10 ++++---
 drivers/net/ethernet/intel/Kconfig                  |  11 ++++++++
 drivers/net/ethernet/intel/i40e/Makefile            |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_osdep.h        |   4 +--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c         | 104 +++++++++++++++++++++++++++++++++++++++++++++++---------------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h         |   1 +
 drivers/net/ethernet/renesas/sh_eth.c               |   9 +++++-
 drivers/net/ethernet/renesas/sh_eth.h               |   5 ++++
 drivers/net/ethernet/ti/cpsw.c                      |  11 ++++++--
 drivers/net/ethernet/ti/cpsw_ale.c                  |  10 ++++++-
 drivers/net/ethernet/ti/cpsw_ale.h                  |   2 +-
 drivers/net/team/team.c                             |  16 +++++++++--
 drivers/net/usb/kaweth.c                            |   2 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c             |   6 ++--
 drivers/net/wireless/iwlwifi/iwl-8000.c             |   2 +-
 drivers/net/wireless/iwlwifi/iwl-fw-file.h          |   4 +++
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h      |   2 ++
 drivers/net/wireless/iwlwifi/mvm/scan.c             |  19 +++++++++----
 drivers/net/wireless/iwlwifi/mvm/tx.c               |   8 ++++--
 drivers/net/wireless/iwlwifi/mvm/utils.c            |   2 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c             |   4 ++-
 drivers/net/wireless/rtlwifi/pci.c                  |  32 +++++++++++++++------
 drivers/net/xen-netfront.c                          |  71 +++++++++++++++++++++++++++-------------------
 include/linux/netdevice.h                           |   6 ++--
 include/uapi/linux/openvswitch.h                    |   4 +++
 net/bridge/br_input.c                               |   3 +-
 net/core/neighbour.c                                |  44 +++++++++++++++++++++++++++++
 net/ipv4/netfilter/nft_redir_ipv4.c                 |   8 +++---
 net/ipv6/netfilter/nft_redir_ipv6.c                 |   8 +++---
 net/netfilter/ipvs/ip_vs_ftp.c                      |  10 +++----
 net/netfilter/nf_conntrack_core.c                   |  20 ++++++-------
 net/netfilter/nf_tables_api.c                       |  14 ++++++----
 net/netfilter/nfnetlink.c                           |   5 ++--
 net/netfilter/nft_nat.c                             |   8 +++---
 net/openvswitch/datapath.c                          |   3 +-
 net/packet/af_packet.c                              |   2 +-
 net/tipc/bcast.c                                    |   5 ++--
 49 files changed, 419 insertions(+), 175 deletions(-)
