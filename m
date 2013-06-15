From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 15 Jun 2013 03:50:20 -0700 (PDT)
Message-ID: <20130615.035020.382818503653292818.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix RTNL locking in batman-adv, from Matthias Schiffer.

2) Don't allow non-passthrough macvlan devices to set NOPROMISC
   via netlink, otherwise we can end up with corrupted promisc
   counter values on the device.  From Michael S. Tsirkin.

3) Fix stmmac driver build with debugging defines enabled, from
   Dinh Nguyen.

4) Make sure name string we give in socket address in AF_PACKET
   is NULL terminated, from Daniel Borkmann.

5) Fix leaking of two uninitialized bytes of memory to userspace
   in l2tp, from Guillaume Nault.

6) Clear IPCB(skb) before tunneling otherwise we touch dangling
   IP options state and crash.  From Saurabh Mohan.

7) Fix suspend/resume for davinci_mdio by using suspend_late
   and resume_early.  From Mugunthan V N.

8) Don't tag ip_tunnel_init_net and ip_tunnel_delete_net
   with __net_{init,exit}, they can be called outside of
   those contexts.  From Eric Dumazet.

9) Fix RX length error in sh_eth driver, from Yoshihiro Shimoda.

10) Fix missing sctp_outq initialization in some code paths of
    SCTP stack, from Neil Horman.

Please pull, thanks a lot!

The following changes since commit 26e04462c8b78d079d3231396ec72d58a14f114b:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-06-12 17:18:29 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to c5c7774d7eb4397891edca9ebdf750ba90977a69:

  sctp: fully initialize sctp_outq in sctp_outq_init (2013-06-13 18:05:24 -0700)

----------------------------------------------------------------
Benjamin Poirier (1):
      netiucv: Hold rtnl between name allocation and device registration.

Daniel Borkmann (1):
      packet: packet_getname_spkt: make sure string is always 0-terminated

David S. Miller (1):
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/linux-merge

Dinh Nguyen (1):
      net: ethernet: stmicro: stmmac: Fix compile error when STMMAC_XMIT_DEBUG used

Eric Dumazet (1):
      ip_tunnel: remove __net_init/exit from exported functions

Guillaume Nault (2):
      l2tp: Fix PPP header erasure and memory leak
      l2tp: Fix sendmsg() return value

Jan Beulich (1):
      xen-netback: don't de-reference vif pointer after having called xenvif_put()

Matthias Schiffer (1):
      batman-adv: wait for rtnl in batadv_store_mesh_iface instead of failing if it is taken

Michael S. Tsirkin (1):
      macvlan: don't touch promisc without passthrough

Mugunthan V N (2):
      drivers: net: davinci_mdio: moving mdio resume earlier than cpsw ethernet driver
      drivers: net: davinci_mdio: restore mdio clk divider in mdio resume

Neil Horman (2):
      tulip: Properly check dma mapping result
      sctp: fully initialize sctp_outq in sctp_outq_init

Nikolay Aleksandrov (2):
      bonding: reset master mac on first enslave failure
      bonding: fix igmp_retrans type and two related races

Nithin Sujir (1):
      tg3: Wait for boot code to finish after power on

Saurabh Mohan (1):
      net/ipv4: ip_vti clear skb cb before tunneling.

Simon Wunderlich (2):
      batman-adv: forward late OGMs from best next hop
      batman-adv: Don't handle address updates when bla is disabled

Somnath Kotur (1):
      be2net: Fix 32-bit DMA Mask handling

Yoshihiro Shimoda (1):
      net: sh_eth: fix incorrect RX length error if R8A7740

 drivers/net/bonding/bond_main.c                   | 19 ++++++++++++++----
 drivers/net/bonding/bonding.h                     |  2 +-
 drivers/net/ethernet/broadcom/tg3.c               | 10 +++++++++
 drivers/net/ethernet/dec/tulip/interrupt.c        |  6 ++++++
 drivers/net/ethernet/emulex/benet/be_main.c       |  3 +++
 drivers/net/ethernet/renesas/sh_eth.c             | 15 ++++++++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |  2 +-
 drivers/net/ethernet/ti/davinci_mdio.c            |  9 +++------
 drivers/net/macvlan.c                             | 20 +++++++++++-------
 drivers/net/xen-netback/netback.c                 | 11 +++++-----
 drivers/s390/net/netiucv.c                        |  6 +++++-
 include/net/ip_tunnels.h                          |  6 +++---
 net/batman-adv/bat_iv_ogm.c                       | 86 ++++++++++++++++++++++++++++++++++++++++++++++++++----------------------------
 net/batman-adv/bridge_loop_avoidance.c            |  4 ++++
 net/batman-adv/sysfs.c                            |  5 +----
 net/ipv4/ip_tunnel.c                              |  4 ++--
 net/ipv4/ip_vti.c                                 |  3 +--
 net/l2tp/l2tp_ppp.c                               |  6 +++---
 net/packet/af_packet.c                            |  5 ++---
 net/sctp/outqueue.c                               |  6 ++----
 20 files changed, 147 insertions(+), 81 deletions(-)
