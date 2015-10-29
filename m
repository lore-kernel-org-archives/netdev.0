From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 29 Oct 2015 08:19:41 -0700 (PDT)
Message-ID: <20151029.081941.1748628899345967916.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752016AbbJ2PC6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 11:02:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is the same as the previous pull request, with the ipv6 overflow
fix redone.  The merge conflict is therefore gone too.

1) Fix two regressions in ipv6 route lookups, particularly wrt. output
   interface specifications in the lookup key.  From David Ahern.

2) Fix checks in ipv6 IPSEC tunnel pre-encap fragmentation, from
   Herbert Xu.

3) Fix mis-advertisement of 1000BASE-T on bcm63xx_enet, from Simon
   Arlott.

4) Some smsc phys misbehave with energy detect mode enabled, so add a
   DT property and disable it on such switches.  From Heiko Schocher.

5) Fix TSO corruption on TX in mv643xx_eth, from Philipp Kirchhofer.

6) Fix regression added by removal of openvswitch vport stats, from
   James Morse.

7) Vendor Kconfig options should be bool, not tristate, from Andreas
   Schwab.

8) Use non-_BH() net stats bump in tcp_xmit_probe_skb(), otherwise
   we barf during TCP REPAIR operations.

9) Fix various bugs in openvswitch conntrack support, from Joe
   Stringer.

10) Fix NETLINK_LIST_MEMBERSHIPS locking, from David Herrmann.

11) Don't have VSOCK do sock_put() in interrupt context, from Jorgen
    Hansen.

12) Fix skb_realloc_headroom() failures properly in ISDN, from Karsten
    Keil.

13) Add some device IDs to qmi_wwan, from Bjorn Mork.

14) Fix ovs egress tunnel information when using lwtunnel devices,
    from Pravin B Shelar.

15) Add missing NETIF_F_FRAGLIST to macvtab feature list, from Jason
    Wang.

16) Fix incorrect handling of throw routes when the result of the
    throw cannot find a match, from Xin Long.

17) Protect ipv6 MTU calculations from wrap-around, from Hannes
    Frederic Sowa.

18) Fix failed autonegotiation on KSZ9031 micrel PHYs, from Nathan
    Sullivan.

19) Add missing memory barries in descriptor accesses or xgbe driver,
    from Thomas Lendacky.

20) Fix release conditon test in pppoe_release(), from Guillaume Nault.

21) Fix gianfar bugs wrt. filter configuration, from Claudiu Manoil.

22) Fix violations of RX buffer alignment in sh_eth driver, from Sergei
    Shtylyov.

23) Fixing missing of_node_put() calls in various places around the
    networking, from Julia Lawall.

24) Fix incorrect leaf now walking in ipv4 routing tree, from Alexander
    Duyck.

25) RDS doesn't check pskb_pull()/pskb_trim() return values, from
    Sowmini Varadhan.

26) Fix VLAN configuration in mlx4 driver, from Jack Morgenstein.

Please pull, thanks a lot.

The following changes since commit 1099f86044111e9a7807f09523e42d4c9d0f=
b781:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-1=
0-19 09:55:40 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 89bc7848a91bc99532f5c21b2885472ba710f249=
:

  ipv6: protect mtu calculation of wrap-around and infinite loop by rou=
nding issues (2015-10-29 07:01:50 -0700)

----------------------------------------------------------------
Alexander Duyck (1):
      fib_trie: leaf_walk_rcu should not compute key if key is less tha=
n pn->key

Andreas Schwab (1):
      net: cavium: change NET_VENDOR_CAVIUM to bool

Andrew F. Davis (1):
      net: phy: dp83848: Add TI DP83848 Ethernet PHY

Andrew Shewmaker (1):
      tcp: allow dctcp alpha to drop to zero

Bj=F8rn Mork (1):
      qmi_wwan: add Sierra Wireless MC74xx/EM74xx

Carol L Soto (1):
      net/mlx4: Copy/set only sizeof struct mlx4_eqe bytes

Claudiu Manoil (4):
      gianfar: Remove duplicated argument to bitwise OR
      gianfar: Don't enable the Filer w/o the Parser
      gianfar: Fix Rx BSY error handling
      MAINTAINERS: Add entry for gianfar ethernet driver

Dan Carpenter (1):
      irda: precedence bug in irlmp_seq_hb_idx()

David Ahern (2):
      net: Really fix vti6 with oif in dst lookups
      net: ipv6: Dont add RT6_LOOKUP_F_IFACE flag if saddr set

David Daney (1):
      net: thunderx: Rewrite silicon revision tests.

David Herrmann (1):
      netlink: fix locking around NETLINK_LIST_MEMBERSHIPS

David S. Miller (12):
      Merge branch 'smsc-energy-detect'
      Merge branch 'mv643xx-fixes'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'isdn-null-deref'
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net-qu=
eue
      Merge branch 'ipv6-overflow-arith'
      Merge branch 'thunderx-fixes'
      Merge branch 'gianfar-fixes'
      Merge branch 'sh_eth-fixes'
      Merge branch 'net_of_node_put'
      Merge branch 'mlx4-fixes'

Eric Dumazet (1):
      ipv6: gre: support SIT encapsulation

=46lorian Westphal (1):
      netfilter: sync with packet rx also after removing queue entries

Gao feng (1):
      vsock: fix missing cleanup when misc_register failed

Guillaume Nault (1):
      ppp: fix pppoe_dev deletion condition in pppoe_release()

Hannes Frederic Sowa (4):
      overflow-arith: begin to add support for overflow builtin functio=
ns
      ipv6: protect mtu calculation of wrap-around and infinite loop by=
 rounding issues
      Revert "Merge branch 'ipv6-overflow-arith'"
      ipv6: protect mtu calculation of wrap-around and infinite loop by=
 rounding issues

Hans de Goede (1):
      net: sun4i-emac: Properly free resources on probe failure and rem=
ove

Heiko Schocher (2):
      drivers: net: cpsw: add phy-handle parsing
      net: phy: smsc: disable energy detect mode

Herbert Xu (1):
      ipv6: Fix IPsec pre-encap fragmentation check

Jack Morgenstein (1):
      net/mlx4_en: Explicitly set no vlan tags in WQE ctrl segment when=
 no vlan is present

James Morse (1):
      openvswitch: Allocate memory for ovs internal device stats.

Jason Wang (1):
      macvtap: unbreak receiving of gro skb with frag list

Jesse Brandeburg (2):
      i40e: fix stats offsets
      i40e: fix annoying message

Joe Jin (1):
      xen-netfront: update num_queues to real created

Joe Stringer (7):
      openvswitch: Reject ct_state masks for unknown bits
      openvswitch: Clarify conntrack COMMIT behaviour
      openvswitch: Mark connections new when not confirmed.
      openvswitch: Serialize nested ct actions if provided
      openvswitch: Fix double-free on ip_defrag() errors
      ipv6: Export nf_ct_frag6_consume_orig()
      openvswitch: Fix skb leak using IPv6 defrag

Jon Paul Maloy (3):
      tipc: extend broadcast link window size
      tipc: allow non-linear first fragment buffer
      tipc: conditionally expand buffer headroom over udp tunnel

Jorgen Hansen (2):
      VSOCK: sock_put wasn't safe to call in interrupt context
      VSOCK: Fix lockdep issue.

Julia Lawall (6):
      net: thunderx: add missing of_node_put
      net: netcp: add missing of_node_put
      netdev/phy: add missing of_node_put
      net: phy: mdio: add missing of_node_put
      ath6kl: add missing of_node_put
      net: mv643xx_eth: add missing of_node_put

Karsten Keil (2):
      ISDN: fix OOM condition for sending queued I-Frames
      mISDN: fix OOM condition for sending queued I-Frames

Lendacky, Thomas (2):
      amd-xgbe: Use wmb before updating current descriptor count
      amd-xgbe: Fix race between access of desc and desc index

Li RongQing (2):
      af_key: fix two typos
      net: sysctl: fix a kmemleak warning

Mathias Krause (1):
      xfrm6: Fix ICMPv6 and MH header checks in _decode_session6

Michael Rossberg (1):
      xfrm: Fix state threshold configuration from userspace

Michael S. Tsirkin (1):
      vhost: fix performance on LE hosts

Nathan Sullivan (1):
      net/phy: micrel: Add workaround for bad autoneg

Neil Horman (1):
      forcedeth: fix unilateral interrupt disabling in netpoll path

Nikolay Borisov (1):
      netfilter: ipset: Fix sleeping memory allocation in atomic contex=
t

Pablo Neira Ayuso (1):
      netfilter: fix Kconfig dependencies for nf_dup_ipv{4,6}

Philipp Kirchhofer (2):
      net: mv643xx_eth: Ensure proper data alignment in TSO TX path
      net: mv643xx_eth: Defer writing the first TX descriptor when usin=
g TSO

Pravin B Shelar (1):
      openvswitch: Fix egress tunnel info.

Renato Westphal (1):
      tcp: remove improper preemption check in tcp_xmit_probe_skb()

Sergei Shtylyov (2):
      sh_eth: fix RX buffer size alignment
      sh_eth: fix RX buffer size calculation

Simon Arlott (1):
      bcm63xx_enet: check 1000BASE-T advertisement configuration

Sowmini Varadhan (1):
      RDS-TCP: Recover correctly from pskb_pull()/pksb_trim() failure i=
n rds_tcp_data_recv

Steffen Klassert (1):
      xfrm: Fix pmtu discovery for local generated packets.

Sunil Goutham (2):
      net: thunderx: Remove PF soft reset.
      net: thunderx: Fix incorrect subsystem devid of VF on pass2 silic=
on

Thanneeru Srinivasulu (1):
      net: thunderx: Incorporate pass2 silicon CPI index configuration =
changes

Yang Shi (1):
      bpf: sample: define aarch64 specific registers

lucien (2):
      netfilter: ipt_rpfilter: remove the nh_scope test in rpfilter_loo=
kup_reverse
      ipv6: fix the incorrect return value of throw route

 Documentation/devicetree/bindings/net/cpsw.txt         |    1 +
 Documentation/devicetree/bindings/net/smsc-lan87xx.txt |   24 ++++++++=
++++
 MAINTAINERS                                            |    8 ++++
 drivers/isdn/hisax/isdnl2.c                            |   20 ++++----=
--
 drivers/isdn/mISDN/layer2.c                            |   54 ++++++++=
++----------------
 drivers/net/ethernet/allwinner/sun4i-emac.c            |   20 ++++++++=
--
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c               |    2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c               |    8 +++-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c           |   33 ++++++++=
+-------
 drivers/net/ethernet/cavium/Kconfig                    |    2 +-
 drivers/net/ethernet/cavium/thunder/nic_main.c         |   42 ++++++++=
+++++-------
 drivers/net/ethernet/cavium/thunder/nic_reg.h          |    4 ++
 drivers/net/ethernet/cavium/thunder/nicvf_main.c       |    2 +-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c      |    4 +-
 drivers/net/ethernet/freescale/gianfar.c               |    8 ++--
 drivers/net/ethernet/freescale/gianfar_ethtool.c       |    4 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c         |    6 +++
 drivers/net/ethernet/intel/i40e/i40e_main.c            |    1 +
 drivers/net/ethernet/marvell/mv643xx_eth.c             |   52 ++++++++=
++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/cmd.c               |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c             |    2 +
 drivers/net/ethernet/mellanox/mlx4/eq.c                |    2 +-
 drivers/net/ethernet/nvidia/forcedeth.c                |   24 ++++++--=
----
 drivers/net/ethernet/renesas/sh_eth.c                  |   14 +++----
 drivers/net/ethernet/ti/cpsw.c                         |   15 ++++++--
 drivers/net/ethernet/ti/netcp_ethss.c                  |    8 +++-
 drivers/net/geneve.c                                   |   40 ++++++++=
+++++++----
 drivers/net/macvtap.c                                  |    2 +-
 drivers/net/phy/Kconfig                                |    5 +++
 drivers/net/phy/Makefile                               |    1 +
 drivers/net/phy/dp83848.c                              |   99 ++++++++=
+++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/mdio-mux-mmioreg.c                     |    2 +
 drivers/net/phy/mdio-mux.c                             |    1 +
 drivers/net/phy/micrel.c                               |   23 ++++++++=
++-
 drivers/net/phy/smsc.c                                 |   19 ++++++--=
-
 drivers/net/ppp/pppoe.c                                |    2 +-
 drivers/net/usb/qmi_wwan.c                             |    4 ++
 drivers/net/vxlan.c                                    |   41 ++++++++=
++++++++++++
 drivers/net/wireless/ath/ath6kl/init.c                 |    1 +
 drivers/net/xen-netfront.c                             |   14 +++----
 drivers/vhost/vhost.h                                  |    7 ++++
 include/linux/netdevice.h                              |    7 ++++
 include/net/dst_metadata.h                             |   32 ++++++++=
+++++++
 include/uapi/linux/openvswitch.h                       |    3 +-
 net/core/dev.c                                         |   27 ++++++++=
+++++
 net/ipv4/fib_trie.c                                    |    2 +-
 net/ipv4/gre_offload.c                                 |    3 +-
 net/ipv4/ip_gre.c                                      |   46 ++++++++=
+++++++++-----
 net/ipv4/netfilter/Kconfig                             |    1 +
 net/ipv4/netfilter/ipt_rpfilter.c                      |    4 +-
 net/ipv4/tcp_dctcp.c                                   |    2 +-
 net/ipv4/tcp_output.c                                  |    2 +-
 net/ipv4/xfrm4_output.c                                |    2 +
 net/ipv6/fib6_rules.c                                  |   19 +++++++-=
-
 net/ipv6/ip6_fib.c                                     |   12 +++++-
 net/ipv6/ip6_output.c                                  |    5 ++-
 net/ipv6/netfilter/Kconfig                             |    1 +
 net/ipv6/netfilter/nf_conntrack_reasm.c                |    1 +
 net/ipv6/route.c                                       |    9 ++++-
 net/ipv6/xfrm6_output.c                                |   18 ++++++--=
-
 net/ipv6/xfrm6_policy.c                                |    6 ++-
 net/irda/irlmp.c                                       |    2 +-
 net/key/af_key.c                                       |    2 +-
 net/netfilter/core.c                                   |    2 +
 net/netfilter/ipset/ip_set_list_set.c                  |    2 +-
 net/netlink/af_netlink.c                               |    4 +-
 net/openvswitch/actions.c                              |   13 +++----
 net/openvswitch/conntrack.c                            |   48 ++++++++=
++++++++-------
 net/openvswitch/conntrack.h                            |   17 +++-----
 net/openvswitch/datapath.c                             |    5 +--
 net/openvswitch/datapath.h                             |    1 -
 net/openvswitch/flow_netlink.c                         |   23 ++++++--=
---
 net/openvswitch/flow_netlink.h                         |    6 +--
 net/openvswitch/vport-geneve.c                         |   13 -------
 net/openvswitch/vport-gre.c                            |    8 ----
 net/openvswitch/vport-internal_dev.c                   |   46 ++++++++=
++++++++++++--
 net/openvswitch/vport-vxlan.c                          |   19 --------=
-
 net/openvswitch/vport.c                                |   58 --------=
--------------------
 net/openvswitch/vport.h                                |   35 --------=
---------
 net/rds/tcp_recv.c                                     |   11 +++++-
 net/sysctl_net.c                                       |    6 ++-
 net/tipc/bcast.c                                       |    8 ++--
 net/tipc/msg.c                                         |   12 ++++--
 net/tipc/udp_media.c                                   |    5 +++
 net/vmw_vsock/af_vsock.c                               |    7 ++--
 net/vmw_vsock/vmci_transport.c                         |  173 ++++++++=
+++++++++++++++++++++++++++++++----------------------------------------=
---
 net/vmw_vsock/vmci_transport.h                         |    4 +-
 net/xfrm/xfrm_user.c                                   |    4 +-
 samples/bpf/bpf_helpers.h                              |   12 ++++++
 89 files changed, 894 insertions(+), 477 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/smsc-lan87xx.=
txt
 create mode 100644 drivers/net/phy/dp83848.c
