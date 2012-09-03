From: pablo@netfilter.org
Subject: [PATCH 00/25] Netfilter updates for net-next
Date: Tue,  4 Sep 2012 01:53:47 +0200
Message-ID: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37087 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754120Ab2ICXz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2012 19:55:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains updates for your net-next tree, the most
relevant thing here is the new IPv6 NAT support from Patrick McHardy.
More specifically, they are:

* Several patches to prepare IPv6 NAT support, including one to improve
  IPv6 fragmentation handling for Netfilter and IPVS from Patrick McHardy
  and Jesper Dangaard respectively.

* IPv6 NAT support for source/destination NAT, masquerading, redirection
  and network mapping, again from Patrick.

* A new target that allows stateless Network Prefix Translation (NPT)
  for IPv6, also from Patrick.

* Changes in existing helpers to support IPv6 NAT, mostly and Patrick and
  a couple from myself.

* Removal of xt_NOTRACK that has now been superseded by the CT target, from
  Cong Wang.

* Minor cleanups from Jan Beulich, Michael Wang and myself.

You can pull these changes from:

git://1984.lsi.us.es/nf-next master

P.S: I merged your net-next tree to nf-next to make sure there were no
conflicts with one recent SIP NAT helper fix pushed to net and Patrick's
SIP helper conversion to support IPv6 NAT.

Thanks!

Cong Wang (1):
  netfilter: remove xt_NOTRACK

Jan Beulich (1):
  netfilter: properly annotate ipv4_netfilter_{init,fini}()

Jesper Dangaard Brouer (1):
  ipvs: IPv6 MTU checking cleanup and bugfix

Michael Wang (2):
  netfilter: pass 'nf_hook_ops' instead of 'list_head' to nf_iterate()
  netfilter: pass 'nf_hook_ops' instead of 'list_head' to nf_queue()

Pablo Neira Ayuso (5):
  netfilter: nf_nat: support IPv6 in IRC NAT helper
  netfilter: nf_nat: support IPv6 in TFTP NAT helper
  netfilter: xt_socket: fix compilation warnings with gcc 4.7
  netfilter: xt_CT: refactorize xt_ct_tg_check
  netfilter: nf_conntrack: add nf_ct_timeout_lookup

Patrick McHardy (15):
  netfilter: nf_conntrack_ipv6: improve fragmentation handling
  netfilter: nf_conntrack_ipv6: fix tracking of ICMPv6 error messages containing fragments
  netfilter: nf_conntrack: restrict NAT helper invocation to IPv4
  netfilter: nf_nat: add protoff argument to packet mangling functions
  netfilter: add protocol independent NAT core
  netfilter: ipv6: expand skb head in ip6_route_me_harder after oif change
  net: core: add function for incremental IPv6 pseudo header checksum updates
  netfilter: ipv6: add IPv6 NAT support
  netfilter: ip6tables: add MASQUERADE target
  netfilter: ip6tables: add REDIRECT target
  netfilter: ip6tables: add NETMAP target
  netfilter: nf_nat: support IPv6 in FTP NAT helper
  netfilter: nf_nat: support IPv6 in amanda NAT helper
  netfilter: nf_nat: support IPv6 in SIP NAT helper
  netfilter: ip6tables: add stateless IPv6-to-IPv6 Network Prefix Translation target

 Documentation/feature-removal-schedule.txt     |    8 -
 arch/m68k/configs/amiga_defconfig              |    1 -
 arch/m68k/configs/apollo_defconfig             |    1 -
 arch/m68k/configs/atari_defconfig              |    1 -
 arch/m68k/configs/bvme6000_defconfig           |    1 -
 arch/m68k/configs/hp300_defconfig              |    1 -
 arch/m68k/configs/mac_defconfig                |    1 -
 arch/m68k/configs/multi_defconfig              |    1 -
 arch/m68k/configs/mvme147_defconfig            |    1 -
 arch/m68k/configs/mvme16x_defconfig            |    1 -
 arch/m68k/configs/q40_defconfig                |    1 -
 arch/m68k/configs/sun3_defconfig               |    1 -
 arch/m68k/configs/sun3x_defconfig              |    1 -
 arch/mips/configs/ar7_defconfig                |    1 -
 arch/mips/configs/bcm47xx_defconfig            |    1 -
 arch/mips/configs/ip22_defconfig               |    1 -
 arch/mips/configs/jazz_defconfig               |    1 -
 arch/mips/configs/malta_defconfig              |    1 -
 arch/mips/configs/markeins_defconfig           |    1 -
 arch/mips/configs/nlm_xlp_defconfig            |    1 -
 arch/mips/configs/nlm_xlr_defconfig            |    1 -
 arch/mips/configs/rm200_defconfig              |    1 -
 arch/powerpc/configs/pmac32_defconfig          |    1 -
 arch/powerpc/configs/ppc64_defconfig           |    1 -
 arch/powerpc/configs/ppc64e_defconfig          |    1 -
 arch/powerpc/configs/ppc6xx_defconfig          |    1 -
 arch/tile/configs/tilegx_defconfig             |    1 -
 arch/tile/configs/tilepro_defconfig            |    1 -
 include/linux/ipv6.h                           |    1 +
 include/linux/netfilter.h                      |   14 +-
 include/linux/netfilter/nf_conntrack_amanda.h  |    1 +
 include/linux/netfilter/nf_conntrack_ftp.h     |    1 +
 include/linux/netfilter/nf_conntrack_h323.h    |   15 +-
 include/linux/netfilter/nf_conntrack_irc.h     |    1 +
 include/linux/netfilter/nf_conntrack_pptp.h    |    2 +
 include/linux/netfilter/nf_conntrack_sip.h     |   21 +-
 include/linux/netfilter/nf_nat.h               |    8 +
 include/linux/netfilter/nfnetlink_conntrack.h  |    8 +-
 include/linux/netfilter_ipv4.h                 |    1 -
 include/linux/netfilter_ipv6/Kbuild            |    1 +
 include/linux/netfilter_ipv6/ip6t_NPT.h        |   16 +
 include/net/addrconf.h                         |    2 +-
 include/net/checksum.h                         |    3 +
 include/net/netfilter/nf_conntrack_expect.h    |    2 +-
 include/net/netfilter/nf_conntrack_timeout.h   |   20 +
 include/net/netfilter/nf_nat.h                 |    6 +-
 include/net/netfilter/nf_nat_core.h            |    5 +-
 include/net/netfilter/nf_nat_helper.h          |   11 +-
 include/net/netfilter/nf_nat_l3proto.h         |   52 ++
 include/net/netfilter/nf_nat_l4proto.h         |   72 ++
 include/net/netfilter/nf_nat_protocol.h        |   67 --
 include/net/netfilter/nf_nat_rule.h            |   15 -
 include/net/netns/conntrack.h                  |    4 +
 include/net/netns/ipv4.h                       |    2 -
 include/net/netns/ipv6.h                       |    1 +
 net/core/secure_seq.c                          |    1 +
 net/core/utils.c                               |   20 +
 net/ipv4/netfilter.c                           |   41 +-
 net/ipv4/netfilter/Kconfig                     |   69 +-
 net/ipv4/netfilter/Makefile                    |   16 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c            |   18 +-
 net/ipv4/netfilter/ipt_NETMAP.c                |   15 +-
 net/ipv4/netfilter/ipt_REDIRECT.c              |   15 +-
 net/ipv4/netfilter/iptable_nat.c               |  320 +++++++++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    8 +-
 net/ipv4/netfilter/nf_nat_amanda.c             |   85 ---
 net/ipv4/netfilter/nf_nat_core.c               |  763 ---------------------
 net/ipv4/netfilter/nf_nat_ftp.c                |  137 ----
 net/ipv4/netfilter/nf_nat_h323.c               |   71 +-
 net/ipv4/netfilter/nf_nat_helper.c             |  458 -------------
 net/ipv4/netfilter/nf_nat_irc.c                |   99 ---
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c       |  281 ++++++++
 net/ipv4/netfilter/nf_nat_pptp.c               |   21 +-
 net/ipv4/netfilter/nf_nat_proto_common.c       |  114 ----
 net/ipv4/netfilter/nf_nat_proto_dccp.c         |  106 ---
 net/ipv4/netfilter/nf_nat_proto_gre.c          |   30 +-
 net/ipv4/netfilter/nf_nat_proto_icmp.c         |   24 +-
 net/ipv4/netfilter/nf_nat_proto_sctp.c         |   96 ---
 net/ipv4/netfilter/nf_nat_proto_tcp.c          |   91 ---
 net/ipv4/netfilter/nf_nat_proto_udp.c          |   82 ---
 net/ipv4/netfilter/nf_nat_proto_udplite.c      |   98 ---
 net/ipv4/netfilter/nf_nat_proto_unknown.c      |   52 --
 net/ipv4/netfilter/nf_nat_rule.c               |  214 ------
 net/ipv4/netfilter/nf_nat_sip.c                |  569 ----------------
 net/ipv4/netfilter/nf_nat_standalone.c         |  326 ---------
 net/ipv4/netfilter/nf_nat_tftp.c               |   51 --
 net/ipv6/addrconf.c                            |    2 +-
 net/ipv6/ip6_output.c                          |    7 +-
 net/ipv6/netfilter.c                           |    8 +
 net/ipv6/netfilter/Kconfig                     |   54 ++
 net/ipv6/netfilter/Makefile                    |    8 +
 net/ipv6/netfilter/ip6t_MASQUERADE.c           |  135 ++++
 net/ipv6/netfilter/ip6t_NETMAP.c               |   94 +++
 net/ipv6/netfilter/ip6t_NPT.c                  |  165 +++++
 net/ipv6/netfilter/ip6t_REDIRECT.c             |   98 +++
 net/ipv6/netfilter/ip6table_nat.c              |  321 +++++++++
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  137 ++--
 net/ipv6/netfilter/nf_conntrack_reasm.c        |   19 +-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c       |  287 ++++++++
 net/ipv6/netfilter/nf_nat_proto_icmpv6.c       |   90 +++
 net/netfilter/Kconfig                          |   62 +-
 net/netfilter/Makefile                         |   19 +-
 net/netfilter/core.c                           |   25 +-
 net/netfilter/ipvs/ip_vs_ftp.c                 |    1 +
 net/netfilter/ipvs/ip_vs_xmit.c                |   28 +-
 net/netfilter/nf_conntrack_amanda.c            |    5 +-
 net/netfilter/nf_conntrack_core.c              |   13 +-
 net/netfilter/nf_conntrack_ftp.c               |    3 +-
 net/netfilter/nf_conntrack_h323_main.c         |  232 ++++---
 net/netfilter/nf_conntrack_irc.c               |    3 +-
 net/netfilter/nf_conntrack_netlink.c           |   35 +-
 net/netfilter/nf_conntrack_pptp.c              |   18 +-
 net/netfilter/nf_conntrack_proto_tcp.c         |    8 +-
 net/netfilter/nf_conntrack_sip.c               |  143 ++--
 net/netfilter/nf_internals.h                   |    4 +-
 net/netfilter/nf_nat_amanda.c                  |   85 +++
 net/netfilter/nf_nat_core.c                    |  856 ++++++++++++++++++++++++
 net/netfilter/nf_nat_ftp.c                     |  143 ++++
 net/netfilter/nf_nat_helper.c                  |  435 ++++++++++++
 net/netfilter/nf_nat_irc.c                     |   93 +++
 net/netfilter/nf_nat_proto_common.c            |  112 ++++
 net/netfilter/nf_nat_proto_dccp.c              |  116 ++++
 net/netfilter/nf_nat_proto_sctp.c              |  103 +++
 net/netfilter/nf_nat_proto_tcp.c               |   85 +++
 net/netfilter/nf_nat_proto_udp.c               |   76 +++
 net/netfilter/nf_nat_proto_udplite.c           |  106 +++
 net/netfilter/nf_nat_proto_unknown.c           |   54 ++
 net/netfilter/nf_nat_sip.c                     |  609 +++++++++++++++++
 net/netfilter/nf_nat_tftp.c                    |   50 ++
 net/netfilter/nf_queue.c                       |   10 +-
 net/netfilter/xt_CT.c                          |  262 ++++----
 net/netfilter/xt_NOTRACK.c                     |   53 --
 net/netfilter/xt_nat.c                         |  170 +++++
 net/netfilter/xt_socket.c                      |   12 +-
 134 files changed, 5959 insertions(+), 4173 deletions(-)
 create mode 100644 include/linux/netfilter_ipv6/ip6t_NPT.h
 create mode 100644 include/net/netfilter/nf_nat_l3proto.h
 create mode 100644 include/net/netfilter/nf_nat_l4proto.h
 delete mode 100644 include/net/netfilter/nf_nat_protocol.h
 delete mode 100644 include/net/netfilter/nf_nat_rule.h
 create mode 100644 net/ipv4/netfilter/iptable_nat.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_amanda.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_core.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_ftp.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_helper.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_irc.c
 create mode 100644 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_proto_common.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_proto_dccp.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_proto_sctp.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_proto_tcp.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_proto_udp.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_proto_udplite.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_proto_unknown.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_rule.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_sip.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_standalone.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_tftp.c
 create mode 100644 net/ipv6/netfilter/ip6t_MASQUERADE.c
 create mode 100644 net/ipv6/netfilter/ip6t_NETMAP.c
 create mode 100644 net/ipv6/netfilter/ip6t_NPT.c
 create mode 100644 net/ipv6/netfilter/ip6t_REDIRECT.c
 create mode 100644 net/ipv6/netfilter/ip6table_nat.c
 create mode 100644 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
 create mode 100644 net/ipv6/netfilter/nf_nat_proto_icmpv6.c
 create mode 100644 net/netfilter/nf_nat_amanda.c
 create mode 100644 net/netfilter/nf_nat_core.c
 create mode 100644 net/netfilter/nf_nat_ftp.c
 create mode 100644 net/netfilter/nf_nat_helper.c
 create mode 100644 net/netfilter/nf_nat_irc.c
 create mode 100644 net/netfilter/nf_nat_proto_common.c
 create mode 100644 net/netfilter/nf_nat_proto_dccp.c
 create mode 100644 net/netfilter/nf_nat_proto_sctp.c
 create mode 100644 net/netfilter/nf_nat_proto_tcp.c
 create mode 100644 net/netfilter/nf_nat_proto_udp.c
 create mode 100644 net/netfilter/nf_nat_proto_udplite.c
 create mode 100644 net/netfilter/nf_nat_proto_unknown.c
 create mode 100644 net/netfilter/nf_nat_sip.c
 create mode 100644 net/netfilter/nf_nat_tftp.c
 delete mode 100644 net/netfilter/xt_NOTRACK.c
 create mode 100644 net/netfilter/xt_nat.c

-- 
1.7.10.4
