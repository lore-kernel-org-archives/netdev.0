From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 26 Apr 2017 15:21:58 -0400 (EDT)
Message-ID: <20170426.152158.403455955531516886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59806 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966069AbdDZTWA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 15:22:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) MLX5 bug fixes from Saeed Mahameed et al.
   a) Release wrong resources when firmware timeout happens
   b) Wrong check for encapsulation size limits
   c) UAR memory leak
   d) ETHTOOL_GRXCLSRLALL fails to fill in info->data

2) Don't cache l3mdev on mis-matches local route, causes
   net devices to leak refs.  From Robert Shearman.

3) Handle fragmented SKBs properly in macsec driver, the problem
   is that we were mis-sizing the sgvec table.  From Jason A.
   Donenfeld.

4) We cannot have checksum offload enabled for inner UDP tunneled
   packet during IPSEC, from Ansis Atteka.

5) Fix double SKB free in ravb driver, from Dan Carpenter.

6) Fix CPU port handling in b53 DSA driver, from Florian Dainelli.

7) Don't use on-stack buffers for usb_control_msg() in CAN usb driver,
   from Maksim Salau.

8) Fix device leak in macvlan driver, from Herbert Xu.  We have to
   purge the broadcast queue properly on port destroy.

9) Fix tx ring entry limit on EF10 devices in sfc driver.  From
   Bert Kenward.

10) Fix memory leaks in team driver, from Pan Bian.

11) Don't setup ipv6_stub before it can be actually used, from Paolo
   Abeni.

12) Fix tipc socket flow control accounting, from Parthasarathy
    Bhuvaragan.

13) Fix crash on module unload in hso driver, from Andreas Kemnade.

14) Fix purging of bridge multicast entries, the problem is that if
    we don't defer it to ndo_uninit it's possible for new entries to
    get added after we purge.  Fix from Xin Long.

15) Don't return garbage for PACKET_HDRLEN getsockopt, from Alexander
    Potapenko.

16) Fix autoneg stall properly in PHY layer, and revert micrel driver
    change that was papering over it.  From Alexander Kochetkov.

17) Don't dereference an ipv4 route as an ipv6 one in the ip6_tunnnel
    code, from Cong Wang.

18) Clear out the congestion control private of the TCP socket in all
    of the right places, from Wei Wang.

19) rawv6_ioctl measures SKB length incorrectly, fix from Jamie
    Bainbridge.

Please pull, thanks a lot!

The following changes since commit 94836ecf1e7378b64d37624fbb81fe48fbd4c772:

  Merge tag 'nfsd-4.11-2' of git://linux-nfs.org/~bfields/linux (2017-04-21 16:37:48 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 105f5528b9bbaa08b526d3405a5bcd2ff0c953c8:

  ipv6: check raw payload size correctly in ioctl (2017-04-26 14:59:35 -0400)

----------------------------------------------------------------
Alexander Kochetkov (1):
      net: phy: fix auto-negotiation stall due to unavailable interrupt

Alexander Potapenko (1):
      net/packet: check length in getsockopt() called with PACKET_HDRLEN

Andreas Kemnade (1):
      net: hso: fix module unloading

Ansis Atteka (1):
      udp: disable inner UDP checksum offloads in IPsec case

Bert Kenward (1):
      sfc: tx ring can only have 2048 entries for all EF10 NICs

Dan Carpenter (2):
      net: tc35815: move free after the dereference
      ravb: Double free on error in ravb_start_xmit()

David Ahern (2):
      net: ipv6: send unsolicited NA if enabled for all interfaces
      net: ipv6: regenerate host route if moved to gc list

David S. Miller (4):
      Merge tag 'mlx5-fixes-2017-04-22' of git://git.kernel.org/.../saeed/linux
      Merge branch 'dsa-b53-58xx-fixes'
      Merge tag 'linux-can-fixes-for-4.11-20170425' of git://git.kernel.org/.../mkl/linux-can
      Revert "phy: micrel: Disable auto negotiation on startup"

Eugenia Emantayev (1):
      net/mlx5e: Fix small packet threshold

Florian Fainelli (3):
      net: dsa: b53: Include IMP/CPU port in dumb forwarding mode
      net: dsa: b53: Implement software reset for 58xx devices
      net: dsa: b53: Fix CPU port for 58xx devices

Herbert Xu (1):
      macvlan: Fix device ref leak when purging bc_queue

Ilan Tayari (1):
      net/mlx5e: Fix ETHTOOL_GRXCLSRLALL handling

Jamie Bainbridge (1):
      ipv6: check raw payload size correctly in ioctl

Jason A. Donenfeld (2):
      macsec: avoid heap overflow in skb_to_sgvec
      macsec: dynamically allocate space for sglist

Maksim Salau (1):
      net: can: usb: gs_usb: Fix buffer on stack

Maor Gottlieb (1):
      net/mlx5: Fix UAR memory leak

Martin KaFai Lau (1):
      net/mlx5e: Fix race in mlx5e_sw_stats and mlx5e_vport_stats

Mohamad Haj Yahia (1):
      net/mlx5: Fix driver load bad flow when having fw initializing timeout

Myungho Jung (1):
      net: core: Prevent from dereferencing null pointer when releasing SKB

Or Gerlitz (3):
      net/mlx5: E-Switch, Correctly deal with inline mode on ConnectX-5
      net/mlx5e: Make sure the FW max encap size is enough for ipv4 tunnels
      net/mlx5e: Make sure the FW max encap size is enough for ipv6 tunnels

Pan Bian (1):
      team: fix memory leaks

Paolo Abeni (1):
      ipv6: move stub initialization after ipv6 setup completion

Parthasarathy Bhuvaragan (2):
      tipc: fix socket flow control accounting error at tipc_send_stream
      tipc: fix socket flow control accounting error at tipc_recv_stream

Robert Shearman (1):
      ipv4: Avoid caching l3mdev dst on mismatched local route

Roman Spycha©©a (1):
      usb: plusb: Add support for PL-27A1

Sabrina Dubroca (1):
      ipv6: fix source routing

Stephane Grosjean (2):
      can: usb: Add support of PCAN-Chip USB stamp module
      can: usb: Kconfig: Add PCAN-USB X6 device in help text

WANG Cong (1):
      ipv6: check skb->protocol before lookup for nexthop

Wei Wang (1):
      tcp: memset ca_priv data to 0 properly

Xin Long (1):
      bridge: move bridge multicast cleanup to ndo_uninit

stephen hemminger (1):
      netvsc: fix calculation of available send sections

sudarsana.kalluru@cavium.com (1):
      qed: Fix error in the dcbx app meta data initialization.

 drivers/net/can/usb/Kconfig                                |  2 ++
 drivers/net/can/usb/gs_usb.c                               | 17 ++++++++++++-----
 drivers/net/can/usb/peak_usb/pcan_usb_core.c               |  2 ++
 drivers/net/can/usb/peak_usb/pcan_usb_core.h               |  2 ++
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c                 | 72 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/b53/b53_common.c                           | 37 +++++++++++++++++++++++++++++++++++--
 drivers/net/dsa/b53/b53_regs.h                             |  5 +++++
 drivers/net/ethernet/mellanox/mlx5/core/en.h               |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c          |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c            | 87 ++++++++++++++++++++++++++++++++++++++++++++++++---------------------------------------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c | 36 ++++++++++++++++++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/main.c             |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/uar.c              |  1 +
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c                 | 10 +++++-----
 drivers/net/ethernet/renesas/ravb_main.c                   |  7 ++++---
 drivers/net/ethernet/sfc/efx.h                             |  5 ++++-
 drivers/net/ethernet/sfc/workarounds.h                     |  1 +
 drivers/net/ethernet/toshiba/tc35815.c                     |  2 +-
 drivers/net/hyperv/hyperv_net.h                            |  1 -
 drivers/net/hyperv/netvsc.c                                |  9 ++++-----
 drivers/net/macsec.c                                       | 27 +++++++++++++++++++++------
 drivers/net/macvlan.c                                      | 11 ++++++++++-
 drivers/net/phy/micrel.c                                   | 11 -----------
 drivers/net/phy/phy.c                                      | 40 ++++++++++++++++++++++++++++++++++++----
 drivers/net/team/team.c                                    |  8 ++++++--
 drivers/net/usb/Kconfig                                    |  2 +-
 drivers/net/usb/hso.c                                      |  2 +-
 drivers/net/usb/plusb.c                                    | 15 +++++++++++++--
 include/linux/phy.h                                        |  1 +
 net/bridge/br_device.c                                     |  1 +
 net/bridge/br_if.c                                         |  1 -
 net/core/dev.c                                             |  3 +++
 net/ipv4/route.c                                           |  3 ++-
 net/ipv4/tcp_cong.c                                        | 11 +++--------
 net/ipv4/udp_offload.c                                     |  3 +++
 net/ipv6/addrconf.c                                        | 14 ++++++++++++--
 net/ipv6/af_inet6.c                                        |  6 ++++--
 net/ipv6/exthdrs.c                                         |  4 ++++
 net/ipv6/ip6_tunnel.c                                      | 34 ++++++++++++++++++----------------
 net/ipv6/ndisc.c                                           |  3 ++-
 net/ipv6/raw.c                                             |  3 +--
 net/packet/af_packet.c                                     |  2 ++
 net/tipc/socket.c                                          |  4 ++--
 44 files changed, 373 insertions(+), 141 deletions(-)
