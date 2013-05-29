From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 2013-05-29b
Date: Wed, 29 May 2013 10:10:30 +0200
Message-ID: <1369815051-708-1-git-send-email-ordex@autistici.org>
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

this is again our pull request intended for net-next/linux-3.11.

Apparently my mail server decided that 14/21 was spam and refused all the
subsequent emails. It's a first step towards the automatic kernel mainten=
ance
:-)

Again:

The only real behavioural change in this batch is the broadcast overhead
reduction on non-wireless interfaces brought by Matthias Schiffer.

The rest is made up by code cleanups and refactoring.

Two highlights on the refactoring are the introduction of
netdev_alloc_skb_ip_align() to avoid to deal with NET_IP_ALIGN manually a=
nd the
introduction of the eth_hdr() wherever it was possible in order to improv=
e
readability.


Please pull or let me know of any problem.

Thanks a lot,
	Antonio



The following changes since commit 06ecf24bdf2b7afc6c8fd13de6dba2a96dd331=
b6:

  net: Fix build warnings after mac_header and transport_header became __=
u16. (2013-05-28 13:15:50 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 6715fd3f0538e805b6a769d66823ec16b8b647ac:

  batman-adv: Start new development cycle (2013-05-29 02:44:56 +0200)

----------------------------------------------------------------
Included changes:
- reduce broadcast overhead on non-lossy wired links
- fix typos in kernel doc
- use eth_hdr() when possible
- use netdev_allock_skb_ip_align() and don't deal with NET_IP_ALIGN
- change VID semantic in the BLA component
- other minor cleanups and code refactoring

----------------------------------------------------------------
Antonio Quartulli (14):
      batman-adv: drop useless argument seqno in neighbor creation
      batman-adv: slightly improve neighbor creation debug message
      batman-adv: don't check the source address twice
      batman-adv: don't check compat version twice
      batman-adv: do not silently ignore wrong condition
      batman-adv: don't initialise batman_iv private members in hard-inte=
rface.c
      batman-adv: use eth_hdr() when it makes sense
      batman-adv: move ring_buffer helper functions in bat_iv_ogm
      batman-adv: move batadv_slide_own_bcast_window to bat_iv_ogm.c
      batman-adv: refactor batadv_tt_local_event()
      batman-adv: don't deal with NET_IP_ALIGN manually
      batman-adv: pass a 16bit long flag argument to tt_global_add()
      batman-adv: change VID semantic in the BLA code
      batman-adv: print the VID properly

Linus L=C3=BCssing (1):
      batman-adv: Remove unnecessary INIT_HLIST_NODE() calls

Marek Lindner (2):
      batman-adv: fix typos in kernel doc & comments
      batman-adv: do not print orig nodes without nc neighbors on nc tabl=
e print

Martin Hundeb=C3=B8ll (1):
      batman-adv: Move call to batadv_nc_skb_forward() from routing.c to =
send.c

Matthias Schiffer (2):
      batman-adv: split batadv_is_wifi_iface() into two functions
      batman-adv: send each broadcast only once on non-wireless interface=
s

Simon Wunderlich (1):
      batman-adv: Start new development cycle

 net/batman-adv/Makefile                |   1 -
 net/batman-adv/bat_iv_ogm.c            | 122 ++++++++++++++++++++++++---=
------
 net/batman-adv/bridge_loop_avoidance.c |  94 +++++++++++++------------
 net/batman-adv/bridge_loop_avoidance.h |  12 ++--
 net/batman-adv/distributed-arp-table.c |  82 +++++++++++-----------
 net/batman-adv/hard-interface.c        |  96 +++++++++++++++-----------
 net/batman-adv/icmp_socket.c           |   4 +-
 net/batman-adv/main.h                  |  18 ++++-
 net/batman-adv/network-coding.c        |  22 +++---
 net/batman-adv/network-coding.h        |   6 +-
 net/batman-adv/originator.c            |   6 +-
 net/batman-adv/originator.h            |   2 +-
 net/batman-adv/ring_buffer.c           |  51 --------------
 net/batman-adv/ring_buffer.h           |  27 --------
 net/batman-adv/routing.c               |  64 +++++------------
 net/batman-adv/routing.h               |   1 -
 net/batman-adv/send.c                  |  36 ++++++----
 net/batman-adv/send.h                  |   6 +-
 net/batman-adv/soft-interface.c        |   6 +-
 net/batman-adv/translation-table.c     |  74 +++++++++++++-------
 net/batman-adv/translation-table.h     |   2 +-
 net/batman-adv/types.h                 |   6 +-
 net/batman-adv/unicast.c               |   2 +-
 net/batman-adv/vis.c                   |  19 ++---
 24 files changed, 395 insertions(+), 364 deletions(-)
 delete mode 100644 net/batman-adv/ring_buffer.c
 delete mode 100644 net/batman-adv/ring_buffer.h
