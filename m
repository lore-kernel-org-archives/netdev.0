From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 00/11] pull request for net-next: batman-adv
	2016-07-04
Date: Mon,  4 Jul 2016 15:02:48 +0200
Message-ID: <1467637379-6089-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi David,

this is our second and final feature pull request for batman-adv in this
round.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 4e3e823b5a503235630921287f130e1d8d22d200:

  batman-adv: Add debugfs table for mcast flags (2016-06-30 10:29:43 +0200)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-next-for-davem-20160704

for you to fetch changes up to 29824a55c07cd79a530d4bc1020a529c402515b6:

  batman-adv: split routing API data structure in subobjects (2016-07-04 12:37:19 +0200)

----------------------------------------------------------------
This feature patchset includes the following changes:

 - Cleanup work by Markus Pargmann and Sven Eckelmann (six patches)

 - Initial Netlink support by Matthias Schiffer (two patches)

 - Throughput Meter implementation by Antonio Quartulli, a kernel-space
   traffic generator to estimate link speeds. This feature is useful on
   low-end WiFi APs where running iperf or netperf from userspace
   gives wrong results due to heavy userspace/kernelspace overhead.
   (two patches)

 - API clean-up work by Antonio Quartulli (one patch)

----------------------------------------------------------------
Antonio Quartulli (3):
      batman-adv: return netdev status in the TX path
      batman-adv: throughput meter implementation
      batman-adv: split routing API data structure in subobjects

Markus Pargmann (1):
      batman-adv: split tvlv into a separate file

Matthias Schiffer (2):
      batman-adv: add generic netlink family for batman-adv
      batman-adv: add netlink command to query generic mesh information files

Sven Eckelmann (5):
      batman-adv: Include main.h in bat_v_ogm.h
      batman-adv: Keep includes ordered by filename
      batman-adv: move bat_algo functions into a separate file
      batman-adv: Consolidate logging related functions
      batman-adv: Fix bat_(iv|v) function declaration header

 MAINTAINERS                            |    1 +
 include/uapi/linux/batman_adv.h        |  114 +++
 net/batman-adv/Makefile                |    5 +
 net/batman-adv/bat_algo.c              |  140 +++
 net/batman-adv/bat_algo.h              |   35 +-
 net/batman-adv/bat_iv_ogm.c            |   40 +-
 net/batman-adv/bat_iv_ogm.h            |   25 +
 net/batman-adv/bat_v.c                 |   29 +-
 net/batman-adv/bat_v.h                 |   52 ++
 net/batman-adv/bat_v_elp.c             |    3 +-
 net/batman-adv/bat_v_elp.h             |    4 +-
 net/batman-adv/bat_v_ogm.c             |    5 +-
 net/batman-adv/bat_v_ogm.h             |    4 +-
 net/batman-adv/bitarray.c              |    2 +
 net/batman-adv/bridge_loop_avoidance.c |    1 +
 net/batman-adv/debugfs.c               |  217 +----
 net/batman-adv/distributed-arp-table.c |    2 +
 net/batman-adv/fragmentation.c         |   41 +-
 net/batman-adv/fragmentation.h         |    6 +-
 net/batman-adv/gateway_client.c        |    1 +
 net/batman-adv/gateway_common.c        |    4 +-
 net/batman-adv/hard-interface.c        |   21 +-
 net/batman-adv/icmp_socket.c           |    1 +
 net/batman-adv/log.c                   |  231 +++++
 net/batman-adv/log.h                   |  111 +++
 net/batman-adv/main.c                  |  707 +--------------
 net/batman-adv/main.h                  |  121 +--
 net/batman-adv/multicast.c             |    2 +
 net/batman-adv/netlink.c               |  424 +++++++++
 net/batman-adv/netlink.h               |   32 +
 net/batman-adv/network-coding.c        |    2 +
 net/batman-adv/originator.c            |   51 +-
 net/batman-adv/packet.h                |   54 ++
 net/batman-adv/routing.c               |   43 +-
 net/batman-adv/send.c                  |   39 +-
 net/batman-adv/soft-interface.c        |    3 +
 net/batman-adv/sysfs.c                 |    7 +-
 net/batman-adv/tp_meter.c              | 1507 ++++++++++++++++++++++++++++++++
 net/batman-adv/tp_meter.h              |   34 +
 net/batman-adv/translation-table.c     |    8 +-
 net/batman-adv/tvlv.c                  |  632 ++++++++++++++
 net/batman-adv/tvlv.h                  |   61 ++
 net/batman-adv/types.h                 |  226 ++++-
 43 files changed, 3831 insertions(+), 1217 deletions(-)
 create mode 100644 include/uapi/linux/batman_adv.h
 create mode 100644 net/batman-adv/bat_algo.c
 create mode 100644 net/batman-adv/bat_iv_ogm.h
 create mode 100644 net/batman-adv/bat_v.h
 create mode 100644 net/batman-adv/log.c
 create mode 100644 net/batman-adv/log.h
 create mode 100644 net/batman-adv/netlink.c
 create mode 100644 net/batman-adv/netlink.h
 create mode 100644 net/batman-adv/tp_meter.c
 create mode 100644 net/batman-adv/tp_meter.h
 create mode 100644 net/batman-adv/tvlv.c
 create mode 100644 net/batman-adv/tvlv.h
