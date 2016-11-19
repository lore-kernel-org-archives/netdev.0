From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 0/8] pull request for net-next: batman-adv
	2016-11-19
Date: Sat, 19 Nov 2016 14:35:20 +0100
Message-ID: <20161119133528.1379-1-sw@simonwunderlich.de>
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

this should be our last feature pull request for batman-adv in this round.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 93bbaab455f30fd43911e0881a02107a17150a62:

  batman-adv: Reject unicast packet with zero/mcast dst address (2016-11-08 19:02:36 +0100)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-next-for-davem-20161119

for you to fetch changes up to 9b4aec647a92a2464337db10507348aecf0f0fd7:

  batman-adv: fix rare race conditions on interface removal (2016-11-08 19:02:39 +0100)

----------------------------------------------------------------
This feature patchset includes the following changes:

 - 6 patches adding functionality to detect a WiFi interface under
   other virtual interfaces, like VLANs. They introduce a cache for
   the detected the WiFi configuration to avoid RTNL locking in
   critical sections. Patches have been prepared by Marek Lindner
   and Sven Eckelmann

 - Enable automatic module loading for genl requests, by Sven Eckelmann

 - Fix a potential race condition on interface removal. This is not
   happening very often in practice, but requires bigger changes to fix,
   so we are sending this to net-next. By Linus Luessing

----------------------------------------------------------------
Linus Lüssing (1):
      batman-adv: fix rare race conditions on interface removal

Marek Lindner (3):
      batman-adv: refactor wifi interface detection
      batman-adv: additional checks for virtual interfaces on top of WiFi
      batman-adv: retrieve B.A.T.M.A.N. V WiFi neighbor stats from real interface

Sven Eckelmann (4):
      batman-adv: Return non-const ptr in batadv_getlink_net
      batman-adv: Cache the type of wifi device for each hardif
      batman-adv: Update wifi flags on upper link change
      batman-adv: Add module alias for batadv netlink family

 net/batman-adv/bat_iv_ogm.c        |  21 +--
 net/batman-adv/bat_v_elp.c         |  41 +++---
 net/batman-adv/hard-interface.c    | 173 +++++++++++++++++++++--
 net/batman-adv/hard-interface.h    |   5 +-
 net/batman-adv/main.c              |   3 +
 net/batman-adv/send.c              | 283 ++++++++++++++++++++++++++++---------
 net/batman-adv/send.h              |   5 +
 net/batman-adv/translation-table.c |  10 +-
 net/batman-adv/types.h             |  19 +++
 9 files changed, 445 insertions(+), 115 deletions(-)
