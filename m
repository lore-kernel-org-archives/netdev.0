From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 31 Oct 2011 04:40:25 -0400 (EDT)
Message-ID: <20111031.044025.134410682817900998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932119Ab1JaIwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2011 04:52:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The majority of the bits here are driver bug fixes, but more notably:

1) icmp6_dst_alloc needs to set the destination address in the route
   before trying to binding the route to an inetpeer entry, since the
   inetpeer is found by destination.  Fix from Gao Feng.

2) Traffic class not set properly for TIME_WAIT sockets, from Eric
   Dumazet.

3) Fix vlan over bonding ARP regression, also from Eric Dumazet.

4) ip6_ufo_append_data() does not propagate errors properly, resulting
   in signal interrupts and hangups looking like memory allocation
   errors.  Fix from Zheng Yan.

5) Refcounting and hash lookup fixes in batman-adv from Simon Wunderlich.

7) Fix races in bond_close() and workqueue deadlocks.  From Jay
   Vosburgh.

8) IPV6 addrconf prefix handling needs to explicitly lookup routes
   in the RT6_TABLE_PREFIX routing table, otherwise it might find
   unrelated routes.  Fix from Andreas Hofmeister.

Please pull, thanks a lot!

The following changes since commit 839d8810747bbf39e0a5a7f223b67bffa7945f8d:

  Merge branch 'i2c-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jdelvare/staging (2011-10-30 15:54:59 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Andreas Hofmeister (1):
      ipv6: fix route lookup in addrconf_prefix_rcv()

Angus Clark (1):
      stmmac: fix NULL pointer dereference in capabilities fixup (v2)

Antonio Quartulli (1):
      batman-adv: unify hash_entry field position in tt_local/global_entry

David S. Miller (1):
      Merge branch 'batman-adv/maint' of git://git.open-mesh.org/linux-merge

Dmitry Kravkov (2):
      bnx2x: use FW 7.0.29.0
      bnx2x: update driver version to 1.70.30-0

Eric Dumazet (2):
      ipv6: tcp: fix TCLASS value in ACK messages sent from TIME_WAIT
      vlan: allow nested vlan_do_receive()

Gao feng (1):
      ipv6: fix route error binding peer in func icmp6_dst_alloc

Geert Uytterhoeven (1):
      i825xx: Fix incorrect dependency for BVME6000_NET

Giuseppe CAVALLARO (2):
      stmmac: fix a bug while checking the HW cap reg (v2)
      stmmac: update normal descriptor structure (v2)

Jay Vosburgh (1):
      bonding: eliminate bond_close race conditions

Simon Wunderlich (2):
      batman-adv: remove references for global tt entries
      batman-adv: add sanity check when removing global tts

Somnath Kotur (2):
      be2net: Refactored be_cmds.c file.
      be2net: Changing MAC Address of a VF was broken.

Sony Chacko (1):
      qlcnic: updated reset sequence

Sritej Velaga (2):
      qlcnic: skip IDC ack check in fw reset path.
      qlcnic: Updated License file

Sucheta Chakraborty (2):
      qlcnic: reset loopback mode if promiscous mode setting fails.
      qlcnic: fix beacon and LED test.

Yaniv Rosner (5):
      bnx2x: Fix LED blink rate for 578xx
      bnx2x: Add link retry to 578xx-KR
      bnx2x: Fix RX/TX problem caused by the MAC layer
      bnx2x: Fix 54618se LED behavior
      bnx2x: Enable changing speed when port type is PORT_DA

Zheng Yan (1):
      ipv6: fix error propagation in ip6_ufo_append_data()

 Documentation/networking/LICENSE.qlcnic            |   51 +---
 drivers/net/bonding/bond_3ad.c                     |    8 +-
 drivers/net/bonding/bond_alb.c                     |   16 +-
 drivers/net/bonding/bond_main.c                    |   96 +++---
 drivers/net/bonding/bonding.h                      |    1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |    4 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   |  217 ++++++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h   |    3 +
 drivers/net/ethernet/emulex/benet/be_cmds.c        |  400 ++++++--------------
 drivers/net/ethernet/emulex/benet/be_main.c        |   28 +-
 drivers/net/ethernet/i825xx/Kconfig                |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   45 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |    2 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |   50 +++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   48 ++-
 drivers/net/ethernet/stmicro/stmmac/common.h       |    8 +-
 drivers/net/ethernet/stmicro/stmmac/descs.h        |   31 +-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |   38 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    8 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   13 +-
 include/linux/if_vlan.h                            |    6 +-
 include/net/inet_timewait_sock.h                   |    1 +
 include/net/ipv6.h                                 |    3 +-
 net/8021q/vlan_core.c                              |    7 +-
 net/batman-adv/translation-table.c                 |   17 +-
 net/batman-adv/types.h                             |    4 +-
 net/core/dev.c                                     |    4 +-
 net/dccp/ipv6.c                                    |    4 +-
 net/ipv4/tcp_minisocks.c                           |    1 +
 net/ipv6/addrconf.c                                |   43 ++-
 net/ipv6/inet6_connection_sock.c                   |    2 +-
 net/ipv6/ip6_output.c                              |    9 +-
 net/ipv6/route.c                                   |    3 +-
 net/ipv6/tcp_ipv6.c                                |   17 +-
 net/sctp/ipv6.c                                    |    2 +-
 39 files changed, 634 insertions(+), 567 deletions(-)
