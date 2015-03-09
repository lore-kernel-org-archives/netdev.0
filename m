From: David Miller <davem@redhat.com>
Subject: [GIT] Networking
Date: Mon, 09 Mar 2015 16:30:36 -0400 (EDT)
Message-ID: <20150309.163036.1533634633370431754.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) nft_compat accidently truncates ethernet protocol to 8-bits, from
   Arturo Borrero.

2) Memory leak in ip_vs_proc_conn(), from Julian Anastasov.

3) Don't allow the space required for nftables rules to exceed the
   maximum value representable in the dlen field.  From Patrick
   McHardy.

4) bcm63xx_enet can accidently leave interrupts permanently disabled
   due to errors in the NAPI polling exit logic.  Fix from
   Nicolas Schichan.

5) Fix OOPSes triggerable by the ping protocol module, due to missing
   address family validations etc.  From Lorenzo Colitti.

6) Don't use RCU locking in sleepable context in team driver, from
   Jiri Pirko.

7) xen-netback miscalculates statistic offset pointers when reporting
   the stats to userspace.  From David Vrabel.

8) Fix a leak of up to 256 pages per VIF destroy in xen-netaback,
   also from David Vrabel.

9) ip_check_defrag() cannot assume that skb_network_offset(),
   particularly when it is used by the AF_PACKET fanout defrag code.
   From Alexander Drozdov.

10) gianfar driver doesn't query OF node names properly when trying to
    determine the number of hw queues available.  Fix it to explicitly
    check for OF nodes named queue-group.  From Tobias Waldekranz.

11) MID field in macb driver should be 12 bits, not 16.  From Punnaiah
    Choudary Kalluri.

12) Fix unintentional regression in traceroute due to timestamp socket
    option changes.  Empty ICMP payloads should be allowed in
    non-timestamp cases.  From Willem de Bruijn.

13) When devices are unregistered, we have to get rid of AF_PACKET
    multicast list entries that point to it via ifindex.  Fix from
    Francesco Ruggeri.

Please pull, thanks a lot!

The following changes since commit 6587457b4b3d663b237a0f95ddf6e67d1828c8ea:

  Merge tag 'dma-buf-for-4.0-rc3' of git://git.kernel.org/pub/scm/linux/kernel/git/sumits/dma-buf (2015-03-04 09:59:51 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to e6441bae326271090755e1707196ad05aa1dc703:

  tipc: fix bug in link failover handling (2015-03-09 16:20:41 -0400)

----------------------------------------------------------------
Ahmed S. Darwish (2):
      can: kvaser_usb: Avoid double free on URB submission failures
      can: kvaser_usb: Read all messages in a bulk-in URB buffer

Alexander Drozdov (1):
      ipv4: ip_check_defrag should not assume that skb_network_offset is zero

Alexey Brodkin (1):
      stmmac: check IRQ availability early on probe

Arnd Bergmann (1):
      ARM: fix typos in smc91x platform data

Arturo Borrero (1):
      netfilter: nft_compat: don't truncate ethernet protocol type to u8

Brian King (1):
      bnx2x: Force fundamental reset for EEH recovery

David S. Miller (4):
      Merge branch 'xgene'
      Merge branch 'xen-netback'
      Merge git://git.kernel.org/.../pablo/nf
      Merge tag 'linux-can-fixes-for-4.0-20150309' of git://git.kernel.org/.../mkl/linux-can

David Vrabel (3):
      xen-netback: return correct ethtool stats
      xen-netback: unref frags when handling a from-guest skb with a frag list
      xen-netback: refactor xenvif_handle_frag_list()

Eric Dumazet (1):
      tcp: align tcp_xmit_size_goal() on tcp_tso_autosize()

Florian Fainelli (1):
      net: bcmgenet: properly disable password matching

Francesco Ruggeri (1):
      net: delete stale packet_mclist entries

Fugang Duan (1):
      net: fec: fix rcv is not last issue when do suspend/resume test

Iyappan Subramanian (3):
      Documentation: dts: Update compatible field description for APM X-Gene
      dtb: change binding name to match with newer firmware DT
      drivers: net: xgene: fix new firmware backward compatibility with older driver

Jiri Pirko (1):
      team: don't traverse port list using rcu in team_set_mac_address

Jon Paul Maloy (1):
      tipc: fix bug in link failover handling

Josh Cartwright (1):
      net: macb: constify macb configuration data

Julian Anastasov (1):
      ipvs: add missing ip_vs_pe_put in sync code

Lorenzo Colitti (1):
      net: ping: Return EAFNOSUPPORT when appropriate.

Marc Kleine-Budde (2):
      MAINTAINERS: linux-can moved to github
      MAINTAINERS: add Marc Kleine-Budde as co maintainer for CAN networking layer

Mark Salter (1):
      net: eth: xgene: fix booting with devicetree

Nicolas Schichan (1):
      bcm63xx_enet: fix poll callback.

Oliver Hartkopp (1):
      can: add missing initialisations in CAN related skbuffs

Pablo Neira Ayuso (3):
      netfilter: nf_tables: fix addition/deletion of elements from commit/abort
      Merge https://git.kernel.org/.../horms/ipvs
      netfilter: nf_tables: fix error handling of rule replacement

Patrick McHardy (3):
      netfilter: nf_tables: fix transaction race condition
      netfilter: nf_tables: check for overflow of rule dlen field
      netfilter: nf_tables: fix userdata length overflow

Peter Senna Tschudin (1):
      bgmac: Clean warning messages

Punnaiah Choudary Kalluri (1):
      net: macb: Correct the MID field length value

Stefan Agner (1):
      net: fec: fix unbalanced clk disable on driver unbind

Stephane Grosjean (1):
      can: peak_usb: fix missing ctrlmode_ init for every dev

Tobias Waldekranz (1):
      net: gianfar: correctly determine the number of queue groups

Willem de Bruijn (1):
      ip: fix error queue empty skb handling

 Documentation/devicetree/bindings/net/apm-xgene-enet.txt |  5 ++++-
 MAINTAINERS                                              |  5 +++--
 arch/arm/mach-pxa/idp.c                                  |  1 +
 arch/arm/mach-pxa/lpd270.c                               |  2 +-
 arch/arm/mach-sa1100/neponset.c                          |  4 ++--
 arch/arm/mach-sa1100/pleb.c                              |  2 +-
 arch/arm64/boot/dts/apm/apm-storm.dtsi                   |  4 ++--
 drivers/net/can/dev.c                                    |  8 ++++++++
 drivers/net/can/usb/kvaser_usb.c                         | 48 +++++++++++++++++++++++++++++++-----------------
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c               |  4 ++++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c           |  2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c         |  4 ++++
 drivers/net/ethernet/broadcom/bcm63xx_enet.c             |  8 ++++----
 drivers/net/ethernet/broadcom/bgmac.c                    |  7 -------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c         |  3 +++
 drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c       |  6 ++++--
 drivers/net/ethernet/cadence/macb.c                      |  8 ++++----
 drivers/net/ethernet/cadence/macb.h                      |  2 +-
 drivers/net/ethernet/freescale/fec_main.c                |  3 +--
 drivers/net/ethernet/freescale/gianfar.c                 | 19 +++++++++++++++++--
 drivers/net/ethernet/smsc/smc91x.c                       |  1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c    | 65 ++++++++++++++++++++++++++++++++++++-----------------------------
 drivers/net/team/team.c                                  |  6 +++---
 drivers/net/xen-netback/interface.c                      |  3 +--
 drivers/net/xen-netback/netback.c                        | 22 ++++++++++++----------
 include/net/netfilter/nf_tables.h                        | 22 +++++++++++++++++++---
 net/can/af_can.c                                         |  3 +++
 net/ipv4/ip_fragment.c                                   | 11 +++++++----
 net/ipv4/ip_sockglue.c                                   | 33 +++++++++++++++++++++++----------
 net/ipv4/ping.c                                          | 12 ++++++++++--
 net/ipv4/tcp.c                                           | 10 +++-------
 net/ipv6/datagram.c                                      | 39 ++++++++++++++++++++++++++++-----------
 net/ipv6/ping.c                                          |  5 +++--
 net/netfilter/ipvs/ip_vs_sync.c                          |  3 +++
 net/netfilter/nf_tables_api.c                            | 61 ++++++++++++++++++++++++++++++++++++-------------------------
 net/netfilter/nft_compat.c                               | 14 +++++++-------
 net/packet/af_packet.c                                   | 22 ++++++++++++++--------
 net/rxrpc/ar-error.c                                     |  4 ++--
 net/tipc/link.c                                          |  7 ++++---
 39 files changed, 311 insertions(+), 177 deletions(-)
