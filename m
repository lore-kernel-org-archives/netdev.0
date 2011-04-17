From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: pull request: batman-adv 2011-04-17
Date: Sun, 17 Apr 2011 21:30:10 +0200
Message-ID: <1303068618-27928-1-git-send-email-sven@narfation.org>
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
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I would like to propose following patches for net-next-2.6/2.6.40. Most o=
f the
stuff is cleanup work to reduce the locking complexity. The only exceptio=
n is
Andrew Lunn's patch, which only adds the initialisation of tx_queue_len.

thanks,
	Sven


The following changes since commit 0ce790e7d736cedc563e1fb4e998babf5a4dbc=
3d:

  Linux 2.6.39-rc1 (2011-03-29 12:09:47 -0700)

are available in the git repository at:
  git://git.open-mesh.org/ecsv/linux-merge.git batman-adv/next

Andrew Lunn (1):
      batman-adv: Set the txqueuelen to zero when creating soft interface

Linus L=C3=BCssing (5):
      batman-adv: Move bonding / iface alternating router search to own f=
unctions
      batman-adv: Make gateway_get_selected type safe
      batman-adv: Simplify gw_check_election(), use gw_get_selected()
      batman-adv: Make orig_node->router an rcu protected pointer
      batman-adv: Protect global TQ window with a spinlock

Marek Lindner (1):
      batman-adv: concentrate all curr_gw related rcu operations in selec=
t/deselect functions

Simon Wunderlich (1):
      batman-adv: protect softif_neigh by rcu

 net/batman-adv/gateway_client.c |  259 ++++++++++++++++-----------
 net/batman-adv/gateway_client.h |    2 +-
 net/batman-adv/icmp_socket.c    |   18 +--
 net/batman-adv/originator.c     |   38 +++-
 net/batman-adv/originator.h     |    1 +
 net/batman-adv/routing.c        |  378 +++++++++++++++++++++------------=
------
 net/batman-adv/send.c           |   19 ++-
 net/batman-adv/soft-interface.c |  115 +++++++++---
 net/batman-adv/types.h          |    7 +-
 net/batman-adv/unicast.c        |    2 +-
 net/batman-adv/vis.c            |   91 +++++-----
 11 files changed, 537 insertions(+), 393 deletions(-)
