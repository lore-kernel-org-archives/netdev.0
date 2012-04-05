From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 2012-04-05
Date: Thu,  5 Apr 2012 12:38:46 +0200
Message-ID: <1333622342-6128-1-git-send-email-ordex@autistici.org>
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

Hello,

This is my first pull-request, so I hope I've done everything in the right way,
but please, fell free to blame me so that I can learn more :-)

I would like to propose the following changes for net-next/3.5. The first patch
just adds a new maintainer for batman-adv; patches from 2 to 5 are cleanups
and little fixes to make batman-adv re-use kernel defines/structures (ETH_ALEN
and bitmap); patch 6 increases the default value of the "hop_penalty" parameter
in order to encourage batman-adv to choose shorter routes; patches from 7 to 16
consist in the renewal of the bridge loop avoidance mechanism (aka BLA2).
BLA2 faces the same problem that STP tries to solve in classical switched
networks, but in a layer 2 mesh. In this case the problem shows up when the user
connects two nodes belonging to the same mesh by means of an ethernet bridge.
It is possible to find much more details about BLA2 in our wiki [1,2,3].

As you can see its compile option is set to 'y' by default, but simply because
this mechanism (actually its old version) was already part of the batman-adv
core, but we decided to possibly let the users choose to remove it whether the
network permits it and so reduce the binary size.

Thank you,
	Antonio

[1] http://www.open-mesh.org/wiki/batman-adv/Bridge-loop-avoidance-II
[2] http://www.open-mesh.org/wiki/batman-adv/Bridge-loop-avoidance-Protocol
[3] http://www.open-mesh.org/wiki/batman-adv/Bridge-loop-avoidance-Testcases

The following changes since commit dd775ae2549217d3ae09363e3edb305d0fa19928:

  Linux 3.4-rc1 (2012-03-31 16:24:09 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 039c70589f5428682e2af706ad0affcfab83c55b:

  batman-adv: add bridge loop avoidance compile option (2012-04-05 11:08:13 +0200)

----------------------------------------------------------------
Included changes:
* add my name to the maintainers list of batman-adv
* some clean up fixes
* increases the default hop-penalty in order to encourage the routing protocol
  to choose shorter routes
* renew the bridge loop avoidance mechanism

The latter mechanism was already present in batman-adv but recently the concept
has been discussed again and here comes the new implementation. Moreover we
added a compile option in order to let expert people, which think that this
mechanism is not helpful at all, disable it and save some space.

----------------------------------------------------------------
Antonio Quartulli (3):
      MAINTAINERS: add additional maintainer for net/batman-adv
      batman-adv: clean up Kconfig
      batman-adv: use ETH_ALEN instead of hardcoded numeric constants

Marek Lindner (1):
      batman-adv: encourage batman to take shorter routes by changing the default hop penalty

Simon Wunderlich (10):
      batman-adv: remove old bridge loop avoidance code
      batman-adv: add basic bridge loop avoidance code
      batman-adv: make bridge loop avoidance switchable
      batman-adv: export claim tables through debugfs
      batman-adv: allow multiple entries in tt_global_entries
      batman-adv: don't let backbone gateways exchange tt entries
      batman-adv: add broadcast duplicate check
      batman-adv: drop STP over batman
      batman-adv: form groups in the bridge loop avoidance
      batman-adv: add bridge loop avoidance compile option

Sven Eckelmann (2):
      batman-adv: Replace bitarray operations with bitmap
      batman-adv: Remove declaration of only locally used functions

 Documentation/ABI/testing/sysfs-class-net-mesh |    9 +
 Documentation/networking/batman-adv.txt        |   19 +-
 MAINTAINERS                                    |    1 +
 net/batman-adv/Kconfig                         |   27 +-
 net/batman-adv/Makefile                        |    1 +
 net/batman-adv/bat_debugfs.c                   |   19 +-
 net/batman-adv/bat_iv_ogm.c                    |   15 +-
 net/batman-adv/bat_sysfs.c                     |    8 +-
 net/batman-adv/bitarray.c                      |  118 +-
 net/batman-adv/bitarray.h                      |   26 +-
 net/batman-adv/bridge_loop_avoidance.c         | 1576 ++++++++++++++++++++++++
 net/batman-adv/bridge_loop_avoidance.h         |   56 +
 net/batman-adv/hard-interface.c                |   18 +-
 net/batman-adv/main.c                          |    9 +-
 net/batman-adv/main.h                          |   11 +-
 net/batman-adv/originator.c                    |    3 +-
 net/batman-adv/packet.h                        |   42 +-
 net/batman-adv/routing.c                       |   27 +-
 net/batman-adv/routing.h                       |    1 -
 net/batman-adv/soft-interface.c                |  495 +-------
 net/batman-adv/soft-interface.h                |    2 -
 net/batman-adv/translation-table.c             |  431 +++++--
 net/batman-adv/translation-table.h             |    8 -
 net/batman-adv/types.h                         |   77 +-
 24 files changed, 2204 insertions(+), 795 deletions(-)
 create mode 100644 net/batman-adv/bridge_loop_avoidance.c
 create mode 100644 net/batman-adv/bridge_loop_avoidance.h
