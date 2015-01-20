From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 19 Jan 2015 20:07:32 -0500 (EST)
Message-ID: <20150119.200732.1458473731331084345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Socket addresses returned in the error queue need to be fully
   initialized before being passed on to userspace, fix from
   Willem de Bruijn.

2) Interrupt handling fixes to davinci_emac driver from Tony
   Lindgren.

3) Fix races between receive packet steering and cpu hotplug, from
   Eric Dumazet.

4) Allowing netlink sockets to subscribe to unknown multicast groups
   leads to crashes, don't allow it.  From Johannes Berg.

5) One to many socket races in SCTP fixed by Daniel Borkmann.

6) Put in a guard against the mis-use of ipv6 atomic fragments, from
   Hagen Paul Pfeifer.

7) Fix promisc mode and ethtool crashes in sh_eth driver, from Ben
   Hutchings.

8) Null deref and double kfree fix in sxgbe driver from Girish K.S
   and Byungho An.

9) cfg80211 deadlock fix from Arik Nemtsov.

Please pull, thanks a lot!

The following changes since commit a6391a924cf5a16761ccd6b45094a7d5b9aeebac:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-01-15 11:17:37 +1300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to a8c1d28ac3925b99b5a939617d3fef1644298ee8:

  s2io: use snprintf() as a safety feature (2015-01-19 19:42:21 -0500)

----------------------------------------------------------------
Ahmed S. Darwish (4):
      can: kvaser_usb: Don't free packets when tight on URBs
      can: kvaser_usb: Reset all URB tx contexts upon channel close
      can: kvaser_usb: Don't send a RESET_CHIP for non-existing channels
      can: kvaser_usb: Don't dereference skb after a netif_rx()

Arik Nemtsov (1):
      cfg80211: fix deadlock during reg chan check

Ben Hutchings (2):
      sh_eth: Fix promiscuous mode on chips without TSU
      sh_eth: Fix ethtool operation crash when net device is down

Byungho An (1):
      net: sxgbe: Fix waring for double kfree()

Dan Carpenter (1):
      s2io: use snprintf() as a safety feature

Daniel Borkmann (1):
      net: sctp: fix race for one-to-many sockets in sendmsg's auto associate

David S. Miller (6):
      Merge tag 'mac80211-for-davem-2015-01-15' of git://git.kernel.org/.../jberg/mac80211
      Merge tag 'linux-can-fixes-for-3.19-20150115' of git://git.kernel.org/.../mkl/linux-can
      Merge branch 'davinci_emac'
      Merge branch 'sh_eth'
      Merge branch 'bgmac'
      Merge branch 'r8152'

Eric Dumazet (1):
      net: rps: fix cpu unplug

Geert Uytterhoeven (1):
      sh_eth: Fix addition of .trscer_err_mask to wrong SoC data

Girish K.S (1):
      net: sxgbe: Fix NULL dereferece when using DT

Hagen Paul Pfeifer (1):
      ipv6: stop sending PTB packets for MTU < 1280

Hauke Mehrtens (2):
      bgmac: register napi before the device
      bgmac: activate irqs only if there is nothing to poll

Johannes Berg (3):
      genetlink: document parallel_ops
      genetlink: disallow subscribing to unknown mcast groups
      genetlink: synchronize socket closing and family removal

John Linville (1):
      mac80211: uninitialized return val in __ieee80211_sta_handle_tspec_ac_params

Marc Kleine-Budde (1):
      MAINTAINERS: update linux-can git repositories

Mugunthan V N (1):
      drivers: net: cpsw: fix cpsw hung with add vlan using vconfig

Oliver Hartkopp (2):
      can: dev: fix crtlmode_supported check
      can: m_can: tag current CAN FD controllers as non-ISO

Or Gerlitz (1):
      net/mlx4: Don't disable vxlan offloads under DMFS-A0 optimized steering

Roger Quadros (1):
      can: c_can: use regmap_update_bits() to modify RAMINIT register

Sriharsha Basavapatna (1):
      be2net: Allow GRE to work concurrently while a VxLAN tunnel is configured

Tony Lindgren (6):
      net: davinci_emac: Fix hangs with interrupts
      net: davinci_emac: Fix runtime pm calls for davinci_emac
      net: davinci_emac: Free clock after checking the frequency
      net: davinci_emac: Fix incomplete code for getting the phy from device tree
      net: davinci_emac: Fix ioremap for devices with MDIO within the EMAC address space
      net: davinci_emac: Add support for emac on dm816x

Willem de Bruijn (1):
      ip: zero sockaddr returned on error queue

hayeswang (2):
      r8152: remove generic_ocp_read before writing
      r8152: remove sram_read

 Documentation/devicetree/bindings/net/davinci_emac.txt |  3 +-
 MAINTAINERS                                            |  6 ++--
 drivers/infiniband/hw/mlx4/main.c                      |  3 +-
 drivers/net/can/c_can/c_can_platform.c                 | 29 ++++++++++-------
 drivers/net/can/dev.c                                  |  8 +++--
 drivers/net/can/m_can/m_can.c                          |  5 +++
 drivers/net/can/usb/kvaser_usb.c                       | 31 +++++++++---------
 drivers/net/ethernet/broadcom/bgmac.c                  | 12 +++----
 drivers/net/ethernet/emulex/benet/be_main.c            | 41 +++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c         |  3 +-
 drivers/net/ethernet/mellanox/mlx4/main.c              |  3 +-
 drivers/net/ethernet/neterion/s2io.c                   | 11 +++++--
 drivers/net/ethernet/renesas/sh_eth.c                  | 32 +++++++++++-------
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c        | 21 ++++++------
 drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c    |  8 ++---
 drivers/net/ethernet/ti/cpsw.c                         | 27 +++++++++------
 drivers/net/ethernet/ti/davinci_emac.c                 | 96 ++++++++++++++++++++++++++++++++++++++++++------------
 drivers/net/usb/r8152.c                                | 30 ++++-------------
 include/linux/genetlink.h                              |  4 +++
 include/net/genetlink.h                                |  7 +++-
 include/uapi/linux/can/netlink.h                       |  1 +
 net/core/dev.c                                         | 20 +++++++++---
 net/ipv4/ip_sockglue.c                                 |  8 ++---
 net/ipv6/datagram.c                                    | 10 ++----
 net/ipv6/route.c                                       |  7 ++--
 net/mac80211/mlme.c                                    |  2 +-
 net/netlink/af_netlink.c                               | 24 ++++++++++----
 net/netlink/af_netlink.h                               |  1 +
 net/netlink/genetlink.c                                | 18 +++++-----
 net/sctp/socket.c                                      |  8 ++++-
 net/wireless/reg.c                                     | 56 ++++++++++++++++++-------------
 31 files changed, 343 insertions(+), 192 deletions(-)
