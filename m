From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 2012-10-28
Date: Sun, 28 Oct 2012 12:17:01 +0100
Message-ID: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
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

this is our first set of changes intended for net-next/linux-3.8.
Here you have a patch by Sven Eckelmann that introduces new lockdep classes for
batman-adv virtual interfaces. Then a patch by Simon Wunderlich that adds a
filter aimed to silently drop ECTP packets (we saw there are still some devices
sending them around and then creating problems to our bridge loop avoidance
mechanism).
The rest are cleanups, minor fixes and a small struct re-shaping.


Thank you very much,
		Antonio



The following changes since commit f019948dbb388eacbc0fb61db1d30e686224df77:

  Merge branch 'master' of git://1984.lsi.us.es/nf-next (2012-10-26 14:40:55 -0400)

are available in the git repository at:


  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 2186a06ac573db625b5864d1feb963c2bf0dacac:

  batman-adv: add kernel-doc for enum batadv_dbg_level (2012-10-27 17:06:38 +0200)

----------------------------------------------------------------
included changes:
- some code cleanups and minor fixes (3 of them were reported by Coverity)
- 'struct hard_iface' re-shaping to improve multi-protocol support
- ECTP packets silent drop
- transfer the WIFI flag on clients in case of roaming

----------------------------------------------------------------
Antonio Quartulli (8):
      batman-adv: use check_unicast_packet() in recv_roam_adv()
      batman-adv: return proper value in case of hash_add failure
      batman-adv: properly store the roaming time
      batman-adv: print packets re-routing on DBG_TT and ratelimit it
      batman-adv: check for more space before accessing the skb
      batman-adv: properly convert flag into a boolean value
      batman-adv: pass the WIFI flag from the local to global entry
      batman-adv: add kernel-doc for enum batadv_dbg_level

Marek Lindner (3):
      batman-adv: split hard_iface struct for each routing protocol
      batman-adv: separate BATADV_ATTR_HIF_UINT sysfs name from hard-iface variable
      batman-adv: consolidate duplicated primary_if checking code

Simon Wunderlich (1):
      batman-adv: don't allow ECTP traffic on batman-adv

Sven Eckelmann (4):
      batman-adv: Set special lockdep classes to avoid lockdep warning
      batman-adv: Remove extra check in batadv_bit_get_packet
      batman-adv: Check return value of try_module_get
      batman-adv: Only increase refcounter once for alternate router

 net/batman-adv/bat_iv_ogm.c            | 43 ++++++++++---------
 net/batman-adv/bitarray.c              | 23 +++++-----
 net/batman-adv/bridge_loop_avoidance.c | 36 +++-------------
 net/batman-adv/debugfs.c               |  6 ++-
 net/batman-adv/gateway_client.c        | 19 ++-------
 net/batman-adv/hard-interface.c        |  4 +-
 net/batman-adv/icmp_socket.c           | 12 ++++--
 net/batman-adv/main.c                  | 46 +++++++++++++++-----
 net/batman-adv/main.h                  | 19 ++++++---
 net/batman-adv/originator.c            | 19 ++-------
 net/batman-adv/routing.c               | 54 +++++++++---------------
 net/batman-adv/soft-interface.c        | 56 ++++++++++++++++++++++++-
 net/batman-adv/sysfs.c                 | 15 +++----
 net/batman-adv/translation-table.c     | 77 +++++++++++++++++-----------------
 net/batman-adv/translation-table.h     |  6 +--
 net/batman-adv/types.h                 | 16 +++++--
 16 files changed, 246 insertions(+), 205 deletions(-)
