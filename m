From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 2012-08-23
Date: Thu, 23 Aug 2012 15:10:09 +0200
Message-ID: <1345727427-20805-1-git-send-email-ordex@autistici.org>
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

this is our set of changes intended for net-next/linux-3.7.
It is mostly composed by style fixes and cleanups. Other than that you ha=
ve a
patch introducing a new table in debugfs (backbone gateways table for the=
 Bridge
Loop Avoidance) and a new mechanism for the TranslationTable component. T=
he
latter allows mesh nodes to immediately detect new clients joining the ne=
twork,
without waiting for any periodic advertisement.

Thank you,
	Antonio




The following changes since commit 0fa7fa98dbcc2789409ed24e885485e645803d=
7f:

  packet: Protect packet sk list with mutex (v2) (2012-08-22 22:58:27 -07=
00)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to fa4f0afcf40361bf67ed3abd520a5fbe12d11166:

  batman-adv: Start new development cycle (2012-08-23 14:20:23 +0200)

----------------------------------------------------------------
Included changes:
- a set of codestyle rearrangements/fixes
- new feature to early detect new joining (mesh-unaware) clients
- a minor fix for the gw-feature
- substitution of shift operations with the BIT() macro
- reorganization of the main batman-adv structure (struct batadv_priv)
- some more (very) minor cleanups and fixes

----------------------------------------------------------------
Antonio Quartulli (5):
      batman-adv: move function arguments on one line
      batman-adv: add reference counting for type batadv_tt_orig_list_ent=
ry
      batman-adv: fix typos in comments
      batman-adv: detect not yet announced clients
      batman-adv: change interface_rx to get orig node

Jonathan Corbet (1):
      batman-adv: remove a misleading comment

Marek Lindner (1):
      batman-adv: convert remaining packet counters to per_cpu_ptr() infr=
astructure

Martin Hundeb=C3=B8ll (2):
      batman-adv: Move batadv_check_unicast_packet()
      batman-adv: Drop tt queries with foreign dest

Simon Wunderlich (4):
      batman-adv: Add the backbone gateway list to debugfs
      batman-adv: correct comments in bridge loop avoidance
      batman-adv: rename bridge loop avoidance claim types
      batman-adv: check batadv_orig_hash_add_if() return code

Sven Eckelmann (5):
      batman-adv: Split batadv_priv in sub-structures for features
      batman-adv: Use BIT(x) macro to calculate bit positions
      batman-adv: Don't break statements after assignment operator
      batman-adv: Reduce accumulated length of simple statements
      batman-adv: Start new development cycle

 Documentation/networking/batman-adv.txt |    7 +-
 net/batman-adv/bat_iv_ogm.c             |   96 ++++---
 net/batman-adv/bridge_loop_avoidance.c  |  214 ++++++++++------
 net/batman-adv/bridge_loop_avoidance.h  |   11 +-
 net/batman-adv/debugfs.c                |   12 +
 net/batman-adv/gateway_client.c         |   53 ++--
 net/batman-adv/hard-interface.c         |   13 +-
 net/batman-adv/main.c                   |   27 +-
 net/batman-adv/main.h                   |   29 +--
 net/batman-adv/packet.h                 |   35 +--
 net/batman-adv/routing.c                |   85 +++----
 net/batman-adv/send.c                   |    8 +-
 net/batman-adv/soft-interface.c         |   79 +++---
 net/batman-adv/soft-interface.h         |    5 +-
 net/batman-adv/translation-table.c      |  416 +++++++++++++++++++------=
------
 net/batman-adv/translation-table.h      |    4 +-
 net/batman-adv/types.h                  |  120 +++++----
 net/batman-adv/unicast.c                |   16 +-
 net/batman-adv/vis.c                    |  144 +++++------
 net/batman-adv/vis.h                    |    2 +-
 20 files changed, 818 insertions(+), 558 deletions(-)
