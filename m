From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 09 May 2016 00:47:03 -0400 (EDT)
Message-ID: <20160509.004703.2099824107437218063.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54362 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbcEIErH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 00:47:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Check klogctl failure correctly, from Colin Ian King.

2) Prevent OOM when under memory pressure in flowcache, from Steffen
   Klassert.

3) Fix info leak in llc and rtnetlink ifmap code, from Kangjie Lu.

4) Memory barrier and multicast handling fixes in bnxt_en, from
   Michael Chan.

5) Endianness bug in mlx5, from Daniel Jurgens.

6) Fix disconnect handling in VSOCK, from Ian Campbell.

7) Fix locking of netdev list walking in get_bridge_ifindices(), from
   Nikolay Aleksandrov.

8) Bridge multicast MLD parser can look at wrong packet offsets, fix
   from Linus L=FCssing.

9) Fix chip hang in qede driver, from Sudarsana Reddy Kalluru.

10) Fix missing setting of encapsulation before inner handling
    completes in udp_offload code, from Jarno Rajahalme.

11) Missing rollbacks during LAG join and flood configuration failures
    in mlxsw driver, from Ido Schimmel.

12) Fix error code checks in netxen driver, from Dan Carpenter.

13) Fix key size in new macsec driver, from Sabrina Dubroca.

14) Fix mlx5/VXLAN dependencies, from Arnd Bergmann.

Please pull, thanks a lot!

The following changes since commit 7391daf2ffc780679d6ab3fad1db2619e5dd=
2c2a:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-0=
5-03 15:07:50 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git=20

for you to fetch changes up to 8846a125de97f96be64ca234906eedfd26ad778e=
:

  Merge branch 'mlx5-build-fix' (2016-05-09 00:21:13 -0400)

----------------------------------------------------------------
Arnd Bergmann (2):
      Revert "net/mlx5: Kconfig: Fix MLX5_EN/VXLAN build issue"
      net/mlx5e: make VXLAN support conditional

Colin Ian King (1):
      tools: bpf_jit_disasm: check for klogctl failure

Dan Carpenter (4):
      netxen: fix error handling in netxen_get_flash_block()
      netxen: reversed condition in netxen_nic_set_link_parameters()
      netxen: netxen_rom_fast_read() doesn't return -1
      qede: uninitialized variable in qede_start_xmit()

Daniel Jurgens (1):
      net/mlx4_en: Fix endianness bug in IPV6 csum calculation

David Ahern (1):
      net: ipv6: tcp reset, icmp need to consider L3 domain

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'bnxt_en-fixes'
      Merge branch 'mlx5-build-fix'

Eric Dumazet (1):
      macvtap: segmented packet is consumed

Ian Campbell (1):
      VSOCK: do not disconnect socket when peer has shutdown SEND only

Ido Schimmel (2):
      mlxsw: spectrum: Fix rollback order in LAG join failure
      mlxsw: spectrum: Add missing rollback in flood configuration

Jarno Rajahalme (2):
      udp_tunnel: Remove redundant udp_tunnel_gro_complete().
      udp_offload: Set encapsulation before inner completes.

Kangjie Lu (2):
      net: fix infoleak in llc
      net: fix infoleak in rtnetlink

Linus L=FCssing (1):
      bridge: fix igmp / mld query parsing

Matthias Brugger (1):
      drivers: net: xgene: Fix error handling

Michael Chan (2):
      bnxt_en: Need memory barrier when processing the completion ring.
      bnxt_en: Setup multicast properly after resetting device.

Nikolay Aleksandrov (1):
      net: bridge: fix old ioctl unlocked net device walk

Sabrina Dubroca (1):
      macsec: key identifier is 128 bits, not 64

Shmulik Ladkani (1):
      Documentation/networking: more accurate LCO explanation

Steffen Klassert (3):
      flowcache: Avoid OOM condition under preasure
      xfrm: Reset encapsulation field of the skb before transformation
      vti: Add pmtu handling to vti_xmit.

Sudarsana Reddy Kalluru (1):
      qede: prevent chip hang when increasing channels

Uwe Kleine-K=F6nig (1):
      net: fec: only clear a queue's work bit if the queue was emptied

 Documentation/networking/checksum-offloads.txt           | 14 +++++++-=
------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c         |  7 ++++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c                | 23 ++++++++=
+++++++++++----
 drivers/net/ethernet/freescale/fec_main.c                | 10 ++++++++=
--
 drivers/net/ethernet/mellanox/mlx4/en_rx.c               |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig          |  8 +++++++-
 drivers/net/ethernet/mellanox/mlx5/core/Makefile         |  3 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en.h             |  2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c        |  4 ++++
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.h          | 11 ++++++++=
+--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c           |  4 ++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c |  8 ++++++++
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c       | 14 ++++++++=
+-----
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c     |  3 ++-
 drivers/net/ethernet/qlogic/qede/qede_main.c             |  8 +++-----
 drivers/net/geneve.c                                     |  5 +++--
 drivers/net/macsec.c                                     | 19 ++++++++=
+++++------
 drivers/net/macvtap.c                                    |  2 +-
 drivers/net/vxlan.c                                      |  5 +++--
 include/linux/netdevice.h                                |  3 +++
 include/net/netns/xfrm.h                                 |  1 +
 include/net/udp_tunnel.h                                 |  9 --------=
-
 include/uapi/linux/if_macsec.h                           |  4 +++-
 net/bridge/br_ioctl.c                                    |  5 +++--
 net/bridge/br_multicast.c                                | 12 +++++++-=
----
 net/core/flow.c                                          | 14 ++++++++=
+++++-
 net/core/rtnetlink.c                                     | 18 ++++++++=
++--------
 net/ipv4/fou.c                                           |  6 ++++--
 net/ipv4/ip_vti.c                                        | 18 ++++++++=
++++++++++
 net/ipv4/udp_offload.c                                   |  8 +++++---
 net/ipv6/icmp.c                                          |  5 ++---
 net/ipv6/tcp_ipv6.c                                      |  7 ++++++-
 net/llc/af_llc.c                                         |  1 +
 net/vmw_vsock/af_vsock.c                                 | 21 +-------=
-------------
 net/xfrm/xfrm_output.c                                   |  3 +++
 tools/net/bpf_jit_disasm.c                               |  3 +++
 36 files changed, 190 insertions(+), 100 deletions(-)
