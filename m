From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request [net]: batman-adv 20151207
Date: Mon,  7 Dec 2015 23:12:11 +0800
Message-ID: <1449501135-30438-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:24205 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933754AbbLGPNi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2015 10:13:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

long time no see :)

I know it starts to be a bit late in the release cycle, but I think that
these 4 small bug-fixes are still worth being merged.

Patch 1 fixes a compatibility issue between our Distributed ARP Table
mechanism and the "early client detection" feature. Such issue creates
an inconsistency in the global translation table leading to user clients
not being reachable anymore. Fix provided by Simon Wunderlich.

Patch 2 is again provided by Simon Wunderlich and fixes another bug
related to the "early client detection" feature. The fix consists in
ensuring that temporary client entries not claimed by any originator
are properly purged instead of being stored all time long till
shutdown.

Patch 3 fixes the function used by the TT hash tables to detect
duplicate entries. At the moment two clients with the same MAC address
but lying in different VLANs are considered the same, while this should
not be the case. Bugfix by Marek Lindner.

Patch 4 fixes an invalid stack access in the batadv_dat_select_candidates()
function where a u32 pointer is accessed as it was a pointer to a
batadv_dat_entry struct (larger than u32). Bugfix provided by Sven
Eckelmann.


Please pull or let me know of any problem!

Thanks a lot,
	Antonio


The following changes since commit 326fcfa5acca446b3f71e99f6d19881145556e5c:

  net: remove unnecessary semicolon in netdev_alloc_pcpu_stats() (2015-12-06 22:32:32 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to b7fe3d4f4a65bc675e737d88071300ea9c4bcddd:

  batman-adv: Fix invalid stack access in batadv_dat_select_candidates (2015-12-07 22:40:21 +0800)

----------------------------------------------------------------
Included changes:
- prevent compatibility issue between DAT and speedy join from creating
  inconsistencies in the global translation table
- make sure temporary TT entries are purged out if not claimed
- fix comparison function used for TT hash table
- fix invalid stack access in batadv_dat_select_candidates()

----------------------------------------------------------------
Marek Lindner (1):
      batman-adv: fix erroneous client entry duplicate detection

Simon Wunderlich (2):
      batman-adv: fix speedy join for DAT cache replies
      batman-adv: avoid keeping false temporary entry

Sven Eckelmann (1):
      batman-adv: Fix invalid stack access in batadv_dat_select_candidates

 net/batman-adv/distributed-arp-table.c |  5 ++++-
 net/batman-adv/routing.c               | 19 +++++++++++++++----
 net/batman-adv/translation-table.c     | 16 ++++++++++++----
 3 files changed, 31 insertions(+), 9 deletions(-)
