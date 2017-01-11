From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 11 Jan 2017 10:22:08 -0500 (EST)
Message-ID: <20170111.102208.1500085515205459622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix rtlwifi crash, from Larry Finger.

2) Memory disclosure in appletalk ipddp routing code, from
   Vlad Tsyrklevich.

3) r8152 can erroneously split an RX packet into multiple URBs if the
   Rx FIFO is not empty when we suspend.  Fix this by waiting for the
   FIFO to empty before suspending.  From Hayes Wang.

4) Two GRO fixes (enter slow path when not enough SKB tail room exists,
   disable frag0 optimizations when there are IPV6 extension headers)
   from Eric Dumazet and Herbert Xu.

5) A series of mlx5e bug fixes (do source udp port offloading for
   tunnels properly, Ip fragment matching fixes, handling firmware
   errors properly when installing TC rules, etc.) from Saeed
   Mahameed, Or Gerlitz, Roi Dayan, Hadar Hen Zion, Gil Rockah, and
   Daniel Jurgens.

6) Two VRF fixes from David Ahern (don't skip multipath selection for VRF
   paths, disallow VRF to be configured with table ID 0).

Please pull, thanks a lot!

The following changes since commit c92f5bdc4b9ba509a93f9e386fbb1fa779d4b0d6:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-01-09 11:58:28 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 24c63bbc18e25d5d8439422aa5fd2d66390b88eb:

  net: vrf: do not allow table id 0 (2017-01-11 10:04:01 -0500)

----------------------------------------------------------------
Alexander Alemayhu (1):
      ipv6: fix typos

Andrew Lutomirski (1):
      orinoco: Use shash instead of ahash for MIC calculations

Anna, Suman (1):
      net: add the AF_QIPCRTR entries to family name tables

Arnd Bergmann (1):
      cgroup: move CONFIG_SOCK_CGROUP_DATA to init/Kconfig

Colin Ian King (1):
      sctp: Fix spelling mistake: "Atempt" -> "Attempt"

Daniel Jurgens (1):
      net/mlx5: Only cancel recovery work when cleaning up device

David Ahern (2):
      net: ipv4: Fix multipath selection with vrf
      net: vrf: do not allow table id 0

David S. Miller (3):
      Merge tag 'wireless-drivers-for-davem-2017-01-10' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge branch 'r8152-fix-autosuspend'
      Merge branch 'mlx5-fixes'

Eric Dumazet (3):
      tcp: do not export tcp_peer_is_proven()
      net: skb_flow_get_be16() can be static
      gro: use min_t() in skb_gro_reset_offset()

Florian Fainelli (1):
      net: dsa: Ensure validity of dst->ds[0]

Gil Rockah (1):
      net/mlx5e: Remove WARN_ONCE from adaptive moderation code

Hadar Hen Zion (1):
      net/mlx5e: Fix kbuild warnings for uninitialized parameters

Herbert Xu (2):
      gro: Enter slow-path if there is no tailroom
      gro: Disable frag0 optimization on IPv6 ext headers

Jean Delvare (1):
      net: phy: Add Meson GXL PHY hardware dependency

Julian Wiedmann (1):
      net/af_iucv: don't use paged skbs for TX on HiperSockets

Larry Finger (1):
      rtlwifi: rtl_usb: Fix missing entry in USB driver's private data

Martin KaFai Lau (1):
      mlx4: Return EOPNOTSUPP instead of ENOTSUPP

Or Gerlitz (6):
      net/mlx5e: Properly handle offloading of source udp port for IP tunnels
      net/mlx5e: Warn when rejecting offload attempts of IP tunnels
      net/mlx5e: TC ipv4 tunnel encap offload error flow fixes
      net/mlx5e: Properly get address type of encapsulation IP headers
      net/mlx5e: Set inline mode requirements for matching on IP fragments
      net/mlx5e: Properly handle FW errors while adding TC rules

Pavel Tikhomirov (1):
      ipv4: make tcp_notsent_lowat sysctl knob behave as true unsigned int

Russell King (1):
      net: phy: marvell: fix Marvell 88E1512 used in SGMII mode

Saeed Mahameed (1):
      net/mlx5e: Un-register uplink representor on nic_disable

Stephen Boyd (1):
      net: qrtr: Mark 'buf' as little endian

Tobias Klauser (1):
      net: socket: Make unnecessarily global sockfs_setattr() static

Vlad Tsyrklevich (1):
      net/appletalk: Fix kernel memory disclosure

Zefir Kurtisi (1):
      phy state machine: failsafe leave invalid RUNNING state

hayeswang (2):
      r8152: split rtl8152_suspend function
      r8152: fix rx issue for runtime suspend

 drivers/net/appletalk/ipddp.c                      |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 13 +++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c |  7 +-----
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 93 +++++++++++++++++++++++++++++++++++++++++++++++++++++------------------------
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  6 +++--
 drivers/net/phy/Kconfig                            |  1 +
 drivers/net/phy/marvell.c                          |  3 ++-
 drivers/net/phy/phy.c                              |  9 ++++++++
 drivers/net/usb/r8152.c                            | 80 ++++++++++++++++++++++++++++++++++++++++++++++++++++--------------
 drivers/net/vrf.c                                  |  4 ++++
 drivers/net/wireless/intersil/orinoco/mic.c        | 44 +++++++++++++++++++++---------------
 drivers/net/wireless/intersil/orinoco/mic.h        |  3 ++-
 drivers/net/wireless/intersil/orinoco/orinoco.h    |  4 ++--
 drivers/net/wireless/realtek/rtlwifi/usb.c         |  1 +
 include/linux/netdevice.h                          |  9 ++++++--
 init/Kconfig                                       |  4 ++++
 net/Kconfig                                        |  4 ----
 net/core/dev.c                                     |  4 +++-
 net/core/flow_dissector.c                          |  4 ++--
 net/core/sock.c                                    |  6 ++---
 net/dsa/dsa2.c                                     | 11 +++++----
 net/ipv4/fib_semantics.c                           |  9 ++++++--
 net/ipv4/sysctl_net_ipv4.c                         |  2 +-
 net/ipv4/tcp_metrics.c                             |  1 -
 net/ipv6/ip6_offload.c                             |  1 +
 net/ipv6/route.c                                   |  4 ++--
 net/iucv/af_iucv.c                                 | 25 ++++++++++++---------
 net/qrtr/qrtr.c                                    |  4 ++--
 net/sctp/outqueue.c                                |  2 +-
 net/socket.c                                       |  2 +-
 31 files changed, 243 insertions(+), 121 deletions(-)
