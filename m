From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 2012-06-18
Date: Mon, 18 Jun 2012 22:39:04 +0200
Message-ID: <1340051963-14836-1-git-send-email-ordex@autistici.org>
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

Hello David,
	here is our first set of changes intended for next-next/linux-3.6.

Patch 2 fixes a major bug in the TranslationTable code where the old valu=
e of
skb->data is used for memory access even if the data was relocated.
Patches 4, 10, 11, 13, 14 are endianess-related cleanups that we wrote th=
anks
to Al Viro's advice and help.
Thanks to Martin Hundeb=C3=B8ll batman-adv now supports the ethtool API a=
nd can
export several counters that are specific to our module (patch 5).
Then patch 16 improves the routing protocol API by making part of the
TranslationTable code routing agnostic.
The rest are minor fixes and other cleanups.

Thank you very much,
		Antonio



The following changes since commit 6fac262526ee91ee66210b8919a4297dcf7d54=
4e:

  ipv4: Cap ADVMSS metric in the FIB rather than the routing cache. (2012=
-06-17 19:47:34 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to dafe94b278e052c3901b137fe6f666f8f92d839a:

  batman-adv: only store changed gw_bandwidth values (2012-06-18 18:01:07=
 +0200)

----------------------------------------------------------------
Included changes:

* major skb->data pointer usage fix
* interval version update
* added get_ethtool_stats() support
* endianess clean up
* routing protocol API improvement wrt TT commit code
* fix locking in hash table code
* minor cleanups and fixes

----------------------------------------------------------------
Al Viro (5):
      batman-adv: get rid of pointless cast in memcpy()
      batman-adv: trivial endianness annotations
      batman-adv: keep batman_ogm_packet ->seqno net-endian all along
      batman-adv: don't bother flipping ->tt_data
      batman-adv: don't bother flipping ->tt_crc

Antonio Quartulli (3):
      batman-adv: fix skb->data assignment
      batman-adv: convert bat_priv->tt_crc from atomic_t to uint16_t
      batman-adv: use DBG_ALL in log_level sysfs definition

Marek Lindner (5):
      batman-adv: avoid characters requiring shell escapes in protocol na=
mes
      batman-adv: ignore trailing CR when comparing protocol names
      batman-adv: return added entries instead of number of possibly adde=
d entries
      batman-adv: turn tt commit code into routing protocol agnostic API
      batman-adv: only store changed gw_bandwidth values

Martin Hundeb=C3=B8ll (1):
      batman-adv: Add get_ethtool_stats() support

Matthias Schiffer (2):
      batman-adv: fix visualization output without neighbors on the prima=
ry interface
      batman-adv: fix locking in hash_add()

Sven Eckelmann (3):
      batman-adv: update internal version number
      batman-adv: Initialize lockdep class keys for hashes
      batman-adv: Return error codes instead of -1 on failures

 Documentation/networking/batman-adv.txt |    5 +
 net/batman-adv/bat_debugfs.c            |   11 +-
 net/batman-adv/bat_iv_ogm.c             |   63 ++++++------
 net/batman-adv/bat_sysfs.c              |    4 +-
 net/batman-adv/bridge_loop_avoidance.c  |   27 +++--
 net/batman-adv/gateway_common.c         |    3 +
 net/batman-adv/hard-interface.c         |    4 +-
 net/batman-adv/hash.c                   |    9 ++
 net/batman-adv/hash.h                   |   19 ++--
 net/batman-adv/icmp_socket.c            |    4 +-
 net/batman-adv/main.c                   |   42 +++++---
 net/batman-adv/main.h                   |   29 +++++-
 net/batman-adv/originator.c             |   18 ++--
 net/batman-adv/packet.h                 |   18 ++--
 net/batman-adv/routing.c                |   23 +++--
 net/batman-adv/send.c                   |   74 +-------------
 net/batman-adv/soft-interface.c         |   66 +++++++++++-
 net/batman-adv/translation-table.c      |  168 ++++++++++++++++++++++++-=
------
 net/batman-adv/translation-table.h      |    7 +-
 net/batman-adv/types.h                  |   22 +++-
 net/batman-adv/vis.c                    |   29 ++++--
 21 files changed, 420 insertions(+), 225 deletions(-)
