From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 00/17] pull request for net-next: batman-adv
	2016-11-08
Date: Tue,  8 Nov 2016 17:45:09 +0100
Message-ID: <20161108164526.7518-1-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
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

this is our first feature pull request for batman-adv. There is one more
set pending after this one.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit a283ad5066cd63f595224c7476001cfc367fdf2e:

  Merge tag 'batadv-next-for-davem-20161027' of git://git.open-mesh.org/linux-merge (2016-10-29 16:26:50 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-next-for-davem-20161108

for you to fetch changes up to 33581cefe4d182d99e9f8a66156507b06e7c9265:

  batman-adv: Reject unicast packet with zero/mcast dst address (2016-10-30 11:11:40 +0100)

----------------------------------------------------------------
This feature and cleanup patchset includes the following changes:

 - netlink and code cleanups by Sven Eckelmann (3 patches)

 - Cleanup and minor fixes by Linus Luessing (3 patches)

 - Speed up multicast update intervals, by Linus Luessing

 - Avoid (re)broadcast in meshes for some easy cases,
   by Linus Luessing

 - Clean up tx return state handling, by Sven Eckelmann (6 patches)

 - Fix some special mac address handling cases, by Sven Eckelmann
   (3 patches)

----------------------------------------------------------------
Linus Lüssing (5):
      batman-adv: Add wrapper for ARP reply creation
      batman-adv: Remove unnecessary lockdep in batadv_mcast_mla_list_free
      batman-adv: Remove unused skb_reset_mac_header()
      batman-adv: Use own timer for multicast TT and TVLV updates
      batman-adv: Simple (re)broadcast avoidance

Sven Eckelmann (12):
      batman-adv: Introduce missing headers for genetlink restructure
      batman-adv: Mark batadv_netlink_ops as const
      batman-adv: Close two alignment holes in batadv_hard_iface
      batman-adv: use consume_skb for non-dropped packets
      batman-adv: Count all non-success TX packets as dropped
      batman-adv: Consume skb in batadv_frag_send_packet
      batman-adv: Consume skb in batadv_send_skb_to_orig
      batman-adv: Consume skb in receive handlers
      batman-adv: Remove dev_queue_xmit return code exception
      batman-adv: Disallow mcast src address for data frames
      batman-adv: Disallow zero and mcast src address for mgmt frames
      batman-adv: Reject unicast packet with zero/mcast dst address

 net/batman-adv/bat_iv_ogm.c            |  30 ++++--
 net/batman-adv/bat_v_elp.c             |  25 +++--
 net/batman-adv/bat_v_ogm.c             |  66 +++++++++++-
 net/batman-adv/distributed-arp-table.c |  67 +++++++-----
 net/batman-adv/fragmentation.c         |  70 ++++++++-----
 net/batman-adv/hard-interface.c        |  52 ++++++++++
 net/batman-adv/hard-interface.h        |  16 +++
 net/batman-adv/main.c                  |  11 +-
 net/batman-adv/main.h                  |   1 +
 net/batman-adv/multicast.c             |  70 ++++++++++---
 net/batman-adv/multicast.h             |   6 --
 net/batman-adv/netlink.c               |   5 +-
 net/batman-adv/network-coding.c        |  35 ++++---
 net/batman-adv/originator.c            |  13 ++-
 net/batman-adv/routing.c               | 180 ++++++++++++++++++++-------------
 net/batman-adv/send.c                  | 140 ++++++++++++++++++-------
 net/batman-adv/send.h                  |   6 +-
 net/batman-adv/soft-interface.c        |   6 +-
 net/batman-adv/tp_meter.c              |   6 --
 net/batman-adv/translation-table.c     |   4 -
 net/batman-adv/tvlv.c                  |   5 +-
 net/batman-adv/types.h                 |  10 +-
 22 files changed, 571 insertions(+), 253 deletions(-)
