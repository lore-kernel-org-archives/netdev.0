From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: pull request: batman-adv 2011-06-20
Date: Mon, 20 Jun 2011 12:16:53 +0200
Message-ID: <1308565025-21293-1-git-send-email-sven@narfation.org>
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

I would like to propose following changes for net-next-2.6/3.1. The
first part (1-4) are only only small cleanup patches. The last 8 patches
are related to Antonio Quartulli's research "Client announcement and
Fast roaming in a Layer-2 mesh network". The technical report isn't
published yet, but will hopefully follow soon. He tried to document all
important parts in some (unofficial) documents [1,2,3].

thanks,
	Sven

[1] http://www.open-mesh.org/wiki/batman-adv/Client-announcement
[2] http://www.open-mesh.org/wiki/batman-adv/Client-roaming
[3] http://www.open-mesh.org/wiki/batman-adv/Uevent


The following changes since commit ecbd532108cb21d9d3770f73e168bad65d14d9eb:

  batman-adv: use NO_FLAGS define instead of hard-coding 0 (2011-06-09 20:40:38 +0200)

are available in the git repository at:
  git://git.open-mesh.org/ecsv/linux-merge.git batman-adv/next

Antonio Quartulli (8):
      batman-adv: Unify the first 3 bytes in each packet
      batman-adv: improved client announcement mechanism
      batman-adv: improved roaming mechanism
      batman-adv: protect the local and the global trans-tables with rcu
      batman-adv: add wrapper function to throw uevent in userspace
      batman-adv: gateway election code refactoring
      batman-adv: throw uevent in userspace on gateway add/change/del event
      batman-adv: improved gateway tq-based selection

David Howells (1):
      batman-adv: count_real_packets() in batman-adv assumes char is signed

Sven Eckelmann (3):
      batman-adv: Move compare_orig to originator.c
      batman-adv: Keep interface_tx as local function
      batman-adv: Reduce usage of char

 net/batman-adv/Kconfig             |    1 +
 net/batman-adv/aggregation.c       |   25 +-
 net/batman-adv/aggregation.h       |    8 +-
 net/batman-adv/bat_sysfs.c         |   73 ++-
 net/batman-adv/bat_sysfs.h         |    2 +
 net/batman-adv/bitarray.c          |    8 +-
 net/batman-adv/bitarray.h          |    8 +-
 net/batman-adv/gateway_client.c    |  238 +++++--
 net/batman-adv/gateway_client.h    |    3 +-
 net/batman-adv/gateway_common.c    |    6 +-
 net/batman-adv/hard-interface.c    |   17 +-
 net/batman-adv/main.c              |   18 +-
 net/batman-adv/main.h              |   27 +-
 net/batman-adv/originator.c        |   17 +-
 net/batman-adv/originator.h        |    8 -
 net/batman-adv/packet.h            |   92 ++-
 net/batman-adv/routing.c           |  317 +++++++--
 net/batman-adv/routing.h           |    7 +-
 net/batman-adv/send.c              |   92 ++-
 net/batman-adv/send.h              |    2 +-
 net/batman-adv/soft-interface.c    |   26 +-
 net/batman-adv/soft-interface.h    |    1 -
 net/batman-adv/translation-table.c | 1428 ++++++++++++++++++++++++++++++------
 net/batman-adv/translation-table.h |   38 +-
 net/batman-adv/types.h             |   64 ++-
 net/batman-adv/unicast.c           |    3 +
 net/batman-adv/vis.c               |   13 +-
 27 files changed, 2080 insertions(+), 462 deletions(-)
