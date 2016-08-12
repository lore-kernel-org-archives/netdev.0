From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 00/19] pull request for net-next: batman-adv
	2016-08-12
Date: Fri, 12 Aug 2016 10:56:36 +0200
Message-ID: <1470992215-11009-1-git-send-email-sw@simonwunderlich.de>
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

this is our first feature pull request for batman-adv, there are at least two
more to come (the bigger features come later).

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 1fe323aa1b2390a0c57fb0b06a782f128d49094c:

  sctp: use event->chunk when it's valid (2016-08-08 14:31:23 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-next-for-davem-20160812

for you to fetch changes up to b5dcbad25219b82408e15e6d775a406be2116af1:

  batman-adv: Fix consistency of update route messages (2016-08-09 07:54:34 +0200)

----------------------------------------------------------------
This feature patchset includes the following changes (mostly
chronological order):

 - bump version strings, by Simon Wunderlich

 - kerneldoc clean up, by Sven Eckelmann

 - enable RTNL automatic loading and according documentation
   changes, by Sven Eckelmann (2 patches)

 - fix/improve interface removal and associated locking, by
   Sven Eckelmann (3 patches)

 - clean up unused variables, by Linus Luessing

 - implement Gateway selection code for B.A.T.M.A.N. V by
   Antonio Quartulli (4 patches)

 - rewrite TQ comparison by Markus Pargmann

 - fix Cocinelle warnings on bool vs integers (by Fenguang Wu/Intels
   kbuild test robot) and bitwise arithmetic operations (by Linus
   Luessing)

 - rewrite packet creation for forwarding for readability and to avoid
   reference count mistakes, by Linus Luessing

 - use kmem_cache for translation table, which results in more efficient
   storing of translation table entries, by Sven Eckelmann

 - rewrite/clarify reference handling for send_skb_unicast, by Sven
   Eckelmann

 - fix debug messages when updating routes, by Sven Eckelmann

----------------------------------------------------------------
Antonio Quartulli (4):
      batman-adv: make the GW selection class algorithm specific
      batman-adv: make GW election code protocol specific
      batman-adv: B.A.T.M.A.N. V - implement GW selection logic
      batman-adv: disable sysfs knobs when GW-mode is not implemented

Linus Lüssing (3):
      batman-adv: Remove unused primary_if and bat_priv variables
      batman-adv: Introduce forward packet creation helper
      batman-adv: Use bitwise instead of arithmetic operator for flags

Markus Pargmann (1):
      batman-adv: iv_ogm, Reduce code duplication

Simon Wunderlich (1):
      batman-adv: Start new development cycle

Sven Eckelmann (9):
      batman-adv: Document optional batadv_algo_ops
      batman-adv: Define module rtnl link name
      batman-adv: Use rtnl link in device creation example
      batman-adv: Modify mesh_iface outside sysfs context
      batman-adv: Revert "postpone sysfs removal when unregistering"
      batman-adv: Avoid sysfs name collision for netns moves
      batman-adv: use kmem_cache for translation table
      batman-adv: Remove orig_node reference handling from send_skb_unicast
      batman-adv: Fix consistency of update route messages

kbuild test robot (1):
      batman-adv: fix boolreturn.cocci warnings

 Documentation/networking/batman-adv.txt |  17 +-
 net/batman-adv/bat_iv_ogm.c             | 347 +++++++++++++++++++++++++-------
 net/batman-adv/bat_v.c                  | 257 ++++++++++++++++++++++-
 net/batman-adv/bridge_loop_avoidance.c  |   2 +-
 net/batman-adv/gateway_client.c         | 222 +++-----------------
 net/batman-adv/gateway_client.h         |   5 +
 net/batman-adv/gateway_common.c         |   5 +-
 net/batman-adv/hard-interface.c         |  26 +--
 net/batman-adv/main.c                   |  17 +-
 net/batman-adv/main.h                   |   2 +-
 net/batman-adv/multicast.c              |   2 +-
 net/batman-adv/routing.c                |  43 ++--
 net/batman-adv/send.c                   | 136 +++++++++----
 net/batman-adv/send.h                   |   6 +
 net/batman-adv/soft-interface.c         |  47 ++---
 net/batman-adv/sysfs.c                  | 183 ++++++++++++++---
 net/batman-adv/translation-table.c      | 169 ++++++++++++++--
 net/batman-adv/translation-table.h      |   3 +
 net/batman-adv/types.h                  |  51 ++++-
 19 files changed, 1092 insertions(+), 448 deletions(-)
