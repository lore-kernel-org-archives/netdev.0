From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 00/16] pull request for net-next: batman-adv
	2016-08-16
Date: Tue, 16 Aug 2016 10:32:28 +0200
Message-ID: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
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

this is our second feature pull request for batman-adv in this round, with
our joint work on netlink and netns support. There will be at least one more
pull request coming later.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit b5dcbad25219b82408e15e6d775a406be2116af1:

  batman-adv: Fix consistency of update route messages (2016-08-09 07:54:34 +0200)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-next-for-davem-20160816

for you to fetch changes up to 4c09a08b47ffac9aa3bc91870aa54c9ae39d9674:

  batman-adv: Indicate netlink socket can be used with netns. (2016-08-09 07:54:43 +0200)

----------------------------------------------------------------
This feature patchset is all about adding netlink support, which should
supersede our debugfs configuration interface in the long run. It is
especially necessary when batman-adv should be used in different
namespaces, since debugfs can not differentiate between those.

More specifically, the following changes are included:

 - Two fixes for namespace handling by Andrew Lunn, checking also the
   namespaces for parent interfaces, and supress debugfs entries
   for non-default netns

 - Implement various netlink commands for the new interface, by
   Matthias Schiffer, Andrew Lunn, Sven Eckelmann and Simon Wunderlich
   (13 patches):
    * routing algorithm list
    * hardif list
    * translation tables (local and global)
    * TTVN for the translation tables
    * originator and neighbor tables for B.A.T.M.A.N. IV
      and B.A.T.M.A.N. V
    * gateway dump functionality for B.A.T.M.A.N. IV
      and B.A.T.M.A.N. V
    * Bridge Loop Avoidance claims, and corresponding BLA group
    * Bridge Loop Avoidance backbone tables

 - Finally, mark batman-adv as netns compatible, by Andrew Lunn (1 patch)

----------------------------------------------------------------
Andrew Lunn (5):
      batman-adv: Handle parent interfaces in a different netns
      batman-adv: Suppress debugfs entries for netns's
      batman-adv: add B.A.T.M.A.N. IV bat_gw_dump implementations
      batman-adv: add B.A.T.M.A.N. Dump BLA claims via netlink
      batman-adv: Indicate netlink socket can be used with netns.

Matthias Schiffer (6):
      batman-adv: netlink: add routing_algo query
      batman-adv: netlink: hardif query
      batman-adv: netlink: add translation table query
      batman-adv: netlink: add originator and neighbor table queries
      batman-adv: add B.A.T.M.A.N. IV bat_{orig, neigh}_dump implementations
      batman-adv: add B.A.T.M.A.N. V bat_{orig, neigh}_dump implementations

Simon Wunderlich (1):
      batman-adv: add backbone table netlink support

Sven Eckelmann (4):
      batman-adv: Provide TTVN in the mesh_info netlink msg
      batman-adv: netlink: add gateway table queries
      batman-adv: add B.A.T.M.A.N. V bat_gw_dump implementations
      batman-adv: Provide bla group in the mesh_info netlink msg

 include/uapi/linux/batman_adv.h        |  94 +++++++
 net/batman-adv/bat_algo.c              |  68 +++++
 net/batman-adv/bat_algo.h              |   3 +
 net/batman-adv/bat_iv_ogm.c            | 471 +++++++++++++++++++++++++++++++++
 net/batman-adv/bat_v.c                 | 465 ++++++++++++++++++++++++++++++++
 net/batman-adv/bridge_loop_avoidance.c | 333 +++++++++++++++++++++++
 net/batman-adv/bridge_loop_avoidance.h |  17 +-
 net/batman-adv/debugfs.c               |  18 ++
 net/batman-adv/gateway_client.c        |  59 +++++
 net/batman-adv/gateway_client.h        |   2 +
 net/batman-adv/hard-interface.c        |  50 +++-
 net/batman-adv/netlink.c               | 217 ++++++++++++++-
 net/batman-adv/netlink.h               |   6 +
 net/batman-adv/originator.c            | 160 +++++++++++
 net/batman-adv/originator.h            |   4 +
 net/batman-adv/packet.h                |  36 ---
 net/batman-adv/translation-table.c     | 377 ++++++++++++++++++++++++++
 net/batman-adv/translation-table.h     |   4 +
 net/batman-adv/types.h                 |  12 +
 19 files changed, 2348 insertions(+), 48 deletions(-)
