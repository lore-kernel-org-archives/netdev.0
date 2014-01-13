From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request: batman-adv 2014-01-13
Date: Mon, 13 Jan 2014 23:31:24 +0100
Message-ID: <1389652298-472-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:28820 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbaAMWdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 17:33:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here you have another pull request intended for net-next/linux-3.14.

Patches from 1 to 8 implement an optimization for multi-interface setups.
It allows batman-adv nodes to take advantage of all the interfaces they
have in a smarter way than what the protocol was doing before. In
a few words this feature allows a single node to make routing decision by
using a sort of "network-wide knowledge". For more details please read [1].
Along with this feature you also have some specific debug facilities that
should make the netadmin life easier in case of troubles.

Patch 11 is adding some compile time checks against the size of the
packets we send over the wire. This should ensure us that no future member
reordering messes up with the padding of those structures.

The remaining patches are minor changes and cleanups. In particular:
- drop the CRC16 dependency from Kbuild
- remove "returns" at the end of void functions
- update release version
- update copyright years to 2014
- add missing sysfs attributes in batman-adv.txt document


Please pull or let me know of any problem!

Thanks a lot,
	Antonio


[1] http://www.open-mesh.org/projects/batman-adv/wiki/Network-wide-multi-link-optimization




The following changes since commit f9577a376e28d7b8367319e103d6511d41c1c5fa:

  Merge branch 'alx_stats' (2014-01-11 20:53:03 -0800)

are available in the git repository at:


  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 12afc36e38b3b6a0ec9bda71632c2285e7fdbab2:

  batman-adv: drop dependency against CRC16 (2014-01-12 14:41:21 +0100)

----------------------------------------------------------------
Included changes:
- drop dependency against CRC16
- move to new release version
- add size check at compile time for packet structs
- update copyright years in every file
- implement new bonding/interface alternation feature

----------------------------------------------------------------
Antonio Quartulli (3):
      batman-adv: remove returns at the end of void functions
      batman-adv: add missing sysfs attributes to README
      batman-adv: drop dependency against CRC16

Simon Wunderlich (11):
      batman-adv: remove bonding and interface alternating
      batman-adv: split tq information in neigh_node struct
      batman-adv: split out router from orig_node
      batman-adv: add WiFi penalty
      batman-adv: consider outgoing interface in OGM sending
      batman-adv: add bonding again
      batman-adv: add debugfs structure for information per interface
      batman-adv: add debugfs support to view multiif tables
      batman-adv: add build checks for packet sizes
      batman-adv: update copyright years for 2014
      batman-adv: Start new development cycle

 Documentation/networking/batman-adv.txt |   9 +-
 net/batman-adv/Kconfig                  |   1 -
 net/batman-adv/Makefile                 |   2 +-
 net/batman-adv/bat_algo.h               |   2 +-
 net/batman-adv/bat_iv_ogm.c             | 882 +++++++++++++++++++++-----------
 net/batman-adv/bitarray.c               |   2 +-
 net/batman-adv/bitarray.h               |   2 +-
 net/batman-adv/bridge_loop_avoidance.c  |   2 +-
 net/batman-adv/bridge_loop_avoidance.h  |   2 +-
 net/batman-adv/debugfs.c                |  91 +++-
 net/batman-adv/debugfs.h                |   4 +-
 net/batman-adv/distributed-arp-table.c  |   5 +-
 net/batman-adv/distributed-arp-table.h  |   2 +-
 net/batman-adv/fragmentation.c          |   2 +-
 net/batman-adv/fragmentation.h          |   2 +-
 net/batman-adv/gateway_client.c         |  88 +++-
 net/batman-adv/gateway_client.h         |   2 +-
 net/batman-adv/gateway_common.c         |   2 +-
 net/batman-adv/gateway_common.h         |   2 +-
 net/batman-adv/hard-interface.c         |  11 +-
 net/batman-adv/hard-interface.h         |  20 +-
 net/batman-adv/hash.c                   |   2 +-
 net/batman-adv/hash.h                   |   2 +-
 net/batman-adv/icmp_socket.c            |   5 +-
 net/batman-adv/icmp_socket.h            |   2 +-
 net/batman-adv/main.c                   |  26 +-
 net/batman-adv/main.h                   |  10 +-
 net/batman-adv/network-coding.c         |  51 +-
 net/batman-adv/network-coding.h         |   9 +-
 net/batman-adv/originator.c             | 536 +++++++++++++++++--
 net/batman-adv/originator.h             |  22 +-
 net/batman-adv/packet.h                 |   2 +-
 net/batman-adv/routing.c                | 429 ++++++----------
 net/batman-adv/routing.h                |  14 +-
 net/batman-adv/send.c                   |  21 +-
 net/batman-adv/send.h                   |   2 +-
 net/batman-adv/soft-interface.c         |   4 +-
 net/batman-adv/soft-interface.h         |   2 +-
 net/batman-adv/sysfs.c                  |   2 +-
 net/batman-adv/sysfs.h                  |   2 +-
 net/batman-adv/translation-table.c      |   8 +-
 net/batman-adv/translation-table.h      |   2 +-
 net/batman-adv/types.h                  | 132 +++--
 43 files changed, 1652 insertions(+), 768 deletions(-)
