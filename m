From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 0/7] pull request for net: batman-adv
	2016-07-08
Date: Fri,  8 Jul 2016 11:49:15 +0200
Message-ID: <1467971362-3607-1-git-send-email-sw@simonwunderlich.de>
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

here are some more bugfix patches which we would like to have integrated
into net, if that is still possible!

Please pull or let me know of any problem!

Thank you,
      Simon

Sven Eckelmann (7):
  batman-adv: Avoid nullptr dereference in bla after vlan_insert_tag
  batman-adv: Avoid nullptr dereference in dat after vlan_insert_tag
  batman-adv: Fix orig_node_vlan leak on orig_node_release
  batman-adv: Fix non-atomic bla_claim::backbone_gw access
  batman-adv: Fix reference leak in batadv_find_router
  batman-adv: Free last_bonding_candidate on release of orig_node
  batman-adv: Fix speedy join in gateway client mode

 net/batman-adv/bridge_loop_avoidance.c | 116 ++++++++++++++++++++++++++-------
 net/batman-adv/distributed-arp-table.c |  10 ++-
 net/batman-adv/originator.c            |  15 +++++
 net/batman-adv/routing.c               |  52 +++++++++++----
 net/batman-adv/send.c                  |   4 +-
 net/batman-adv/types.h                 |   6 +-
 6 files changed, 161 insertions(+), 42 deletions(-)

-- 
2.8.1

The following changes since commit 5b4d10f5e0369ed79434593b7cd8e85eebbe473f:

  qlcnic: use the correct ring in qlcnic_83xx_process_rcv_ring_diag() (2016-06-29 05:46:16 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-net-for-davem-20160708

for you to fetch changes up to d1fe176ca51fa3cb35f70c1d876d9a090e9befce:

  batman-adv: Fix speedy join in gateway client mode (2016-07-06 16:03:40 +0200)

----------------------------------------------------------------
Here are a couple batman-adv bugfix patches, all by Sven Eckelmann:

 - Fix possible NULL pointer dereference for vlan_insert_tag (two patches)

 - Fix reference handling in some features, which may lead to reference
   leaks or invalid memory access (four patches)

 - Fix speedy join: DHCP packets handled by the gateway feature should
   be sent with 4-address unicast instead of 3-address unicast to make
   speedy join work. This fixes/speeds up DHCP assignment for clients
   which join a mesh for the first time. (one patch)

----------------------------------------------------------------
Sven Eckelmann (7):
      batman-adv: Avoid nullptr dereference in bla after vlan_insert_tag
      batman-adv: Avoid nullptr dereference in dat after vlan_insert_tag
      batman-adv: Fix orig_node_vlan leak on orig_node_release
      batman-adv: Fix non-atomic bla_claim::backbone_gw access
      batman-adv: Fix reference leak in batadv_find_router
      batman-adv: Free last_bonding_candidate on release of orig_node
      batman-adv: Fix speedy join in gateway client mode

 net/batman-adv/bridge_loop_avoidance.c | 116 ++++++++++++++++++++++++++-------
 net/batman-adv/distributed-arp-table.c |  10 ++-
 net/batman-adv/originator.c            |  15 +++++
 net/batman-adv/routing.c               |  52 +++++++++++----
 net/batman-adv/send.c                  |   4 +-
 net/batman-adv/types.h                 |   6 +-
 6 files changed, 161 insertions(+), 42 deletions(-)
