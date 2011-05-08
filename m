From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: pull request: batman-adv 2011-05-08
Date: Sun,  8 May 2011 17:24:36 +0200
Message-ID: <1304868284-9364-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I would like to propose following patches for net-next-2.6/2.6.40. They
include minor cleanups of comments, a big rename patch s/hna/tt/, but
also a remove some duplicated code. The spinlock which protected the
list of possible interfaces for batman-adv was completely replaced by
rtnl_lock because we want to be in sync with the rest of the network
stack and the extra spinlock made everything more complex without giving
any additional feature (and rtnl_lock was already used everywhere).
Related to this patch is also a fix which should prevent a deadlock
between the sysfs code and the event listener. Also the reference
counting in find_router was fixed when an error was detected after the
refcounter was already increased. The only feature is the support for
multiple vlans in the bridge loop detection code.

I will submit a patch to remove the atomic_dec_not_zero from main.h
after Linus accepted the patch you already saw.

thanks,
	Sven


The following changes since commit 32ae9b221e788413ce68feaae2ca39e406211a0a:

  batman-adv: Make bat_priv->primary_if an rcu protected pointer (2011-05-01 22:49:03 +0200)

are available in the git repository at:
  git://git.open-mesh.org/ecsv/linux-merge.git batman-adv/next

Antonio Quartulli (1):
      batman-adv: rename everything from *hna* into *tt* (translation table)

Daniele Furlan (1):
      batman-adv: remove duplicate code from function is_bidirectional_neigh()

Marek Lindner (3):
      batman-adv: remove misplaced comment
      batman-adv: multi vlan support for bridge loop detection
      batman-adv: Fix refcount imbalance in find_router

Sven Eckelmann (3):
      batman-adv: Remove unnecessary hardif_list_lock
      batman-adv: Avoid deadlock between rtnl_lock and s_active
      batman-adv: Remove multiline comments from line ending

 Documentation/networking/batman-adv.txt |   11 +-
 net/batman-adv/aggregation.c            |   16 +-
 net/batman-adv/aggregation.h            |    4 +-
 net/batman-adv/bat_debugfs.c            |    4 +-
 net/batman-adv/bat_sysfs.c              |   16 +-
 net/batman-adv/hard-interface.c         |   36 +--
 net/batman-adv/main.c                   |   20 +-
 net/batman-adv/main.h                   |   42 ++--
 net/batman-adv/originator.c             |   10 +-
 net/batman-adv/packet.h                 |    5 +-
 net/batman-adv/routing.c                |  162 ++++++-------
 net/batman-adv/routing.h                |    6 +-
 net/batman-adv/send.c                   |   16 +-
 net/batman-adv/send.h                   |    2 +-
 net/batman-adv/soft-interface.c         |  409 +++++++++++++++++++++---------
 net/batman-adv/translation-table.c      |  417 ++++++++++++++++---------------
 net/batman-adv/translation-table.h      |   24 +-
 net/batman-adv/types.h                  |   49 +++--
 net/batman-adv/unicast.c                |    2 +-
 net/batman-adv/vis.c                    |   18 +-
 20 files changed, 712 insertions(+), 557 deletions(-)
