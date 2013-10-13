From: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Subject: pull request: batman-adv 2013-10-13
Date: Sun, 13 Oct 2013 13:22:45 +0200
Message-ID: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
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

Hello David,

this is our second pull request intended for net-next/linux-3.13.

The most important piece in this patchset is the new packet fragmentation=
 code
implemented by Martin Hundeb=C3=B8ll during his Google Summer of Code 201=
2[1]. This
code is entirely substituting the current fragmentation mechanism.

Other than this you have:
- the creation of a common BAT ICMP header which makes the ICMP subsystem=
 more
  flexible and extensible
- the addition of a dummy rx mode handler for the soft-interface which al=
lows
  users to set static multicast listeners
- some minor improvements and code cleanups


Please pull or let me know of any problem.

Thank you very much,
		Antonio


[1] http://www.open-mesh.org/projects/batman-adv/wiki/Fragmentation


The following changes since commit ccdbb6e96beca362db876d820ac1e560ff6d95=
79:

  tcp: tcp_transmit_skb() optimizations (2013-10-11 17:48:18 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to a4deee1ad42d93746562fe7de2149729017e3fd1:

  batman-adv: Add dummy soft-interface rx mode handler (2013-10-12 17:17:=
12 +0200)

----------------------------------------------------------------
Included changes:
- ensure RecordRoute information is added to BAT_ICMP echo_request/reply =
only
- use VLAN_ETH_HLEN when possible
- use htons when possible
- substitute old fragmentation code with a new improved implementation by
  Martin Hundeb=C3=B8ll
- create common header for BAT_ICMP packets to improve extendibility
- consider the network coding overhead when computing the overall room ne=
eded by
  batman headers
- add dummy soft-interface rx mode handler
- minor code refactoring and cleanups

----------------------------------------------------------------
Antonio Quartulli (9):
      batman-adv: make tt_global_add static and return bool
      batman-adv: remove batadv_tt_global_add_orig declaration
      batman-adv: don't use call_rcu if not needed
      batman-adv: h_vlan_encapsulated_proto access refactoring
      batman-adv: use VLAN_ETH_HLEN instead of sizeof(struct vlan_eth_hdr=
)
      batman-adv: use htons when possible
      batman-adv: create common header for ICMP packets
      batman-adv: implement batadv_tt_entries
      batman-adv: make batadv_tt_save_orig_buffer() generic

Linus L=C3=BCssing (1):
      batman-adv: Add dummy soft-interface rx mode handler

Marek Lindner (1):
      batman-adv: consider network coding overhead when calculating requi=
red mtu

Martin Hundeb=C3=B8ll (3):
      batman-adv: Remove old fragmentation code
      batman-adv: Receive fragmented packets and merge
      batman-adv: Fragment and send skbs larger than mtu

Simon Wunderlich (2):
      batman-adv: only add recordroute information to icmp request/reply
      batman-adv: remove useless find_router look up

 net/batman-adv/Makefile                |   2 +-
 net/batman-adv/bridge_loop_avoidance.c |  14 +-
 net/batman-adv/distributed-arp-table.c |  11 +-
 net/batman-adv/fragmentation.c         | 491 +++++++++++++++++++++++++++=
++++++
 net/batman-adv/fragmentation.h         |  50 ++++
 net/batman-adv/gateway_client.c        |  23 +-
 net/batman-adv/hard-interface.c        |  22 +-
 net/batman-adv/icmp_socket.c           |  22 +-
 net/batman-adv/main.c                  |  37 ++-
 net/batman-adv/main.h                  |  10 +
 net/batman-adv/originator.c            |  19 +-
 net/batman-adv/packet.h                |  79 ++++--
 net/batman-adv/routing.c               | 185 ++++++-------
 net/batman-adv/routing.h               |   4 +-
 net/batman-adv/send.c                  | 186 ++++++++++++-
 net/batman-adv/send.h                  |  40 +++
 net/batman-adv/soft-interface.c        |  34 ++-
 net/batman-adv/translation-table.c     |  63 +++--
 net/batman-adv/translation-table.h     |   7 -
 net/batman-adv/types.h                 |  70 +++--
 net/batman-adv/unicast.c               | 491 ---------------------------=
------
 net/batman-adv/unicast.h               |  92 ------
 22 files changed, 1105 insertions(+), 847 deletions(-)
 create mode 100644 net/batman-adv/fragmentation.c
 create mode 100644 net/batman-adv/fragmentation.h
 delete mode 100644 net/batman-adv/unicast.c
 delete mode 100644 net/batman-adv/unicast.h
