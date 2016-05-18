From: Antonio Quartulli <a@unstable.cc>
Subject: pull request: batman-adv 20160518
Date: Wed, 18 May 2016 13:04:44 +0800
Message-ID: <1463547892-11290-1-git-send-email-a__27168.5259686366$1463547978$gmane$org@unstable.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:26238 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790AbcERFGB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 01:06:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

these are the fixes that couldn't make it for linux-4.6 rebased on top
of net-next.

They were all supposed to be applied on 4.6, therefore it would be nice
if you could queue them for inclusion in the 4.6.1 stable release.

Please pull or let me know of any problem!


I also have a question: I have another bugfix that should only be
applied to 4.6 and not to 4.7/net-next - should I directly send it
to stable@vger.kernel.org ?


Thanks a lot,
	Antonio

The following changes since commit 917fa5353da05e8a0045b8acacba8d50400d=
5b12:

  Revert "phy dp83867: Fix compilation with CONFIG_OF_MDIO=3Dm" (2016-0=
5-17 14:49:55 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to ebe24cea95ab969f76f2922032f6c390fdc816f2=
:

  batman-adv: initialize ELP orig address on secondary interfaces (2016=
-05-18 11:49:44 +0800)

----------------------------------------------------------------
During the Wireless Battle Mesh v9 in Porto (PT) at the beginning of
May, we managed to uncover and fix some important bugs in our
new B.A.T.M.A.N. V algorithm. These are the fixes we came up with
together with others that I collected in the past weeks:
- avoid potential crash due to NULL pointer dereference in
  B.A.T.M.A.N. V routine when a neigh_ifinfo object is not found, by
  Sven Eckelmann
- avoid use-after-free of skb when counting outgoing bytes, by Florian
  Westphal
- fix neigh_ifinfo object reference counting imbalance when using
  B.A.T.M.A.N. V, by Sven Eckelmann. Such imbalance may lead to the
  impossibility of releasing the related netdev object on shutdown
- avoid invalid memory access in case of error while allocating
  bcast_own_sum when a new hard-interface is added, by Sven Eckelmann
- ensure originator address is updated in OMG/ELP packet content upon
  primary interface address change, by Antonio Quartulli
- fix integer overflow when computing TQ metric (B.A.T.M.A.N. IV), by
  Sven Eckelmann
- avoid race condition while adding new neigh_node which would result
  in having two objects mapping to the same physical neighbour, by
  Linus L=C3=BCssing
- ensure originator address is initialized in ELP packet content on
  secondary interfaces, by Marek Lindner

----------------------------------------------------------------
Antonio Quartulli (1):
      batman-adv: make sure ELP/OGM orig MAC is updated on address chan=
ge

=46lorian Westphal (1):
      batman-adv: fix skb deref after free

Linus L=C3=BCssing (1):
      batman-adv: Avoid duplicate neigh_node additions

Marek Lindner (1):
      batman-adv: initialize ELP orig address on secondary interfaces

Sven Eckelmann (4):
      batman-adv: Avoid nullptr derefence in batadv_v_neigh_is_sob
      batman-adv: Fix refcnt leak in batadv_v_neigh_*
      batman-adv: Fix unexpected free of bcast_own on add_if error
      batman-adv: Fix integer overflow in batadv_iv_ogm_calc_tq

 net/batman-adv/bat_iv_ogm.c |  9 +++----
 net/batman-adv/bat_v.c      | 66 +++++++++++++++++++++++++++++++++++++=
++------
 net/batman-adv/bat_v_elp.c  | 31 ++++++++++++++-------
 net/batman-adv/bat_v_elp.h  |  2 ++
 net/batman-adv/originator.c |  6 +++--
 net/batman-adv/routing.c    |  4 ++-
 6 files changed, 93 insertions(+), 25 deletions(-)
