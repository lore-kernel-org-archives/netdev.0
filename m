From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request: batman-adv 2013-10-09
Date: Wed,  9 Oct 2013 14:40:02 +0200
Message-ID: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:1261 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819Ab3JIMku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 08:40:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a set of changes intended for net-next/linux-3.13.

As introduced one year ago (http://article.gmane.org/gmane.org.freifunk.batman/8484)
in the last period we have been busy working on giving our batman-adv
protocol/packet-format all those means to get stable and avoid incompatibilities
in the near future (this is also why we did not send many changes for
linux-3.12..).

With this patchset we are finally switching to a new compatibility version and
within this development cycle I will send you all those changes aimed to
introduce all the needed mechanism to avoid any further compatibility breakage.

First of all, in this batch you have the new TVLV code (Type Version Value
Length) which is the first very important milestone towards our goal[1].
With this mechanism we will be able to improve/change the packet contents layout
(used by the various features) without breaking compatibility with older
protocol versions anymore.
The development of this new component has been started by Spyros Gasteratos
during his Google Summer of Code 2012 and then adjusted, finished and submitted
by Marek Lindner.

Together with it, you have a set of improvements that we are allowed to apply
thanks to the switching to the new compat version.
These changes are:
- adapt the existing features to make them use the new TVLV mechanism
- move from CRC16 to CRC32c for table correctness check in the TT component
- reorder some of the flags sent over the wire
- remove the __packed attribute from the OGM packet struct.

Moreover, with this patchset we are totally removing our VISualisation component
that is now implemented in userspace.


Please pull let me know of any problem.



Thank you,
	Antonio

[1] http://www.open-mesh.org/projects/batman-adv/wiki/TVLV



The following changes since commit f69b923a758f598fd6bb69e57564b59506f4f1fc:

  udp: fix a typo in __udp4_lib_mcast_demux_lookup (2013-10-09 01:51:57 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 7c4b3ec9d1f92256a31ff64d8a25a1a4fa1b86c3:

  batman-adv: reorder batadv_iv_flags (2013-10-09 13:11:38 +0200)

----------------------------------------------------------------
Included changes:
- update emails for A. Quartulli and M. Lindner in MAINTAINERS
- switch to the next on-the-wire protocol version
- introduce the T(ype) V(ersion) L(ength) V(alue) framework
- adjust the existing components to make them use the new TVLV code
- make the TT component use CRC32 instead of CRC16
- totally remove the VIS functionality (has been moved to userspace)
- reorder packet types and flags
- add static checks on packet format
- remove __packed from batadv_ogm_packet

----------------------------------------------------------------
Antonio Quartulli (4):
      MAINTAINERS: batman-adv - update emails
      batman-adv: switch to a new packet compatibility version
      batman-adv: use CRC32C instead of CRC16 in TT code
      batman-adv: move BATADV_TT_CLIENT_TEMP to higher bit

Marek Lindner (7):
      batman-adv: tvlv - basic infrastructure
      batman-adv: tvlv - gateway download/upload bandwidth container
      batman-adv: tvlv - add distributed arp table container
      batman-adv: tvlv - add network coding container
      batman-adv: tvlv - convert tt data sent within OGMs
      batman-adv: tvlv - convert tt query packet to use tvlv unicast packets
      batman-adv: tvlv - convert roaming adv packet to use tvlv unicast packets

Simon Wunderlich (5):
      batman-adv: remove vis functionality
      batman-adv: add build check macros for packet member offset
      batman-adv: reorder packet types
      batman-adv: remove packed from batadv_ogm_packet
      batman-adv: reorder batadv_iv_flags

 Documentation/ABI/testing/sysfs-class-net-mesh |  11 -
 Documentation/networking/batman-adv.txt        |  50 +-
 MAINTAINERS                                    |   4 +-
 net/batman-adv/Makefile                        |   1 -
 net/batman-adv/bat_iv_ogm.c                    | 111 +--
 net/batman-adv/debugfs.c                       |   9 -
 net/batman-adv/distributed-arp-table.c         |  64 ++
 net/batman-adv/distributed-arp-table.h         |   5 +
 net/batman-adv/gateway_client.c                | 187 +++--
 net/batman-adv/gateway_client.h                |   2 +-
 net/batman-adv/gateway_common.c                | 230 +++---
 net/batman-adv/gateway_common.h                |  14 +-
 net/batman-adv/hard-interface.c                |   9 -
 net/batman-adv/main.c                          | 623 +++++++++++++++-
 net/batman-adv/main.h                          |  37 +-
 net/batman-adv/network-coding.c                |  63 ++
 net/batman-adv/network-coding.h                |   5 +
 net/batman-adv/originator.c                    |   4 +-
 net/batman-adv/packet.h                        | 248 ++++---
 net/batman-adv/routing.c                       | 247 ++-----
 net/batman-adv/routing.h                       |   6 +-
 net/batman-adv/send.c                          |   1 -
 net/batman-adv/soft-interface.c                |   4 +-
 net/batman-adv/sysfs.c                         |  96 +--
 net/batman-adv/translation-table.c             | 906 ++++++++++++++----------
 net/batman-adv/translation-table.h             |  13 +-
 net/batman-adv/types.h                         | 178 ++---
 net/batman-adv/vis.c                           | 938 -------------------------
 net/batman-adv/vis.h                           |  36 -
 29 files changed, 1968 insertions(+), 2134 deletions(-)
 delete mode 100644 net/batman-adv/vis.c
 delete mode 100644 net/batman-adv/vis.h
