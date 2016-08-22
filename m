From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 00/20] pull request for net-next: batman-adv
	2016-08-16*
Date: Mon, 22 Aug 2016 15:56:00 +0200
Message-ID: <20160822135620.15337-1-sw@simonwunderlich.de>
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

this is our third (and final, for now) pull request for batman-adv in this round,
with mostly maintainability stuff.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 4c09a08b47ffac9aa3bc91870aa54c9ae39d9674:

  batman-adv: Indicate netlink socket can be used with netns. (2016-08-09 07:54:43 +0200)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-next-for-davem-20160822

for you to fetch changes up to dc1cbd145eecf21209d0322874e1766bcbce3e3f:

  batman-adv: Allow to disable debugfs support (2016-08-09 07:54:54 +0200)

----------------------------------------------------------------
This feature patchset includes the following changes:

 - place kref_get near usage of referenced objects, separate patches
   for various used objects to improve readability and maintainability
   by Sven Eckelmann (18 patches)

 - Keep batadv net device when all hard interfaces disappear, to
   improve situations where tools currently use work arounds, by
   Sven Eckelmann

 - Add an option to disable debugfs support to minimize footprint when
   userspace uses netlink only, by Sven Eckelmann

----------------------------------------------------------------
Sven Eckelmann (20):
      batman-adv: Place kref_get for orig_node_vlan near use
      batman-adv: Place kref_get for orig_ifinfo near use
      batman-adv: Place kref_get for tt_orig_list_entry near use
      batman-adv: Place kref_get for neigh_ifinfo near use
      batman-adv: Place kref_get for neigh_node near use
      batman-adv: Place kref_get for orig_node near use
      batman-adv: Place kref_get for tt_local_entry near use
      batman-adv: Place kref_get for tt_common near use
      batman-adv: Place kref_get for bla_claim near use
      batman-adv: Place kref_get for bla_backbone_gw near use
      batman-adv: Place kref_get for dat_entry near use
      batman-adv: Place kref_get for gw_node near use
      batman-adv: Place kref_get for hard_iface near use
      batman-adv: Place kref_get for softif_vlan near use
      batman-adv: Place kref_get for nc_node near use
      batman-adv: Place kref_get for nc_path near use
      batman-adv: Place kref_get for tvlv_container near use
      batman-adv: Place kref_get for tvlv_handler near use
      batman-adv: Keep batadv netdev when hardif disappears
      batman-adv: Allow to disable debugfs support

 net/batman-adv/Kconfig                 | 15 +++++++++++++--
 net/batman-adv/Makefile                |  4 ++--
 net/batman-adv/bat_algo.c              |  2 ++
 net/batman-adv/bat_iv_ogm.c            | 19 ++++++++++++++++---
 net/batman-adv/bat_v.c                 | 12 ++++++++++++
 net/batman-adv/bat_v_ogm.c             |  5 ++---
 net/batman-adv/bridge_loop_avoidance.c | 13 ++++++++-----
 net/batman-adv/debugfs.h               |  2 +-
 net/batman-adv/distributed-arp-table.c |  4 +++-
 net/batman-adv/gateway_client.c        | 10 ++++++++--
 net/batman-adv/hard-interface.c        |  8 +++-----
 net/batman-adv/icmp_socket.h           | 18 +++++++++++++++++-
 net/batman-adv/main.c                  |  2 ++
 net/batman-adv/multicast.c             |  2 ++
 net/batman-adv/network-coding.c        | 11 ++++++-----
 net/batman-adv/originator.c            | 12 ++++++++----
 net/batman-adv/soft-interface.c        |  4 ++++
 net/batman-adv/translation-table.c     | 10 +++++++---
 net/batman-adv/tvlv.c                  |  9 +++++++++
 net/batman-adv/types.h                 |  6 ++++++
 20 files changed, 131 insertions(+), 37 deletions(-)
