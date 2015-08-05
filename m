From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request [net]: batman-adv fixes 20150805
Date: Wed,  5 Aug 2015 14:51:43 +0200
Message-ID: <1438779107-12665-1-git-send-email-antonio__43971.9358263121$1438779229$gmane$org@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:46757 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752065AbbHEMxF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 08:53:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here you have our patchset for net/linux-4.2 which contains only patches
that we think to be important (meaning they fix critical
crashes/misbehaviours actually reported by some users).

Patch 1 (by me) is preventing DAT from injecting replies received from the
mesh into the LAN which would confuse a L2 bridge.

Patch 2 introduces several NULL checks in order to prevent spurious
kernel crashes due to NULL pointer deferences, by Marek Lindnder.

Patches 3, still by Marek, prevent accidental double deletions
of tt_local_entry objects from their own lists which would lead to a
kernel crash.

Patch 4 by Simon Wunderlich fixes a memory leak which is triggered by
the missing initialization of the bandwidth_up/down fields of the bat-GW
struct.


If possible, I'd recommend to consider all these patches for inclusion
in the stable releases.



Please pull or let me know if anything else is wrong!

Thanks a lot David,
	Antonio




The following changes since commit 2475b22526d70234ecfe4a1ff88aed69badefba9:

  xen-netback: Allocate fraglist early to avoid complex rollback (2015-08-03 22:23:03 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to 27a4d5efd417b6ef3190e9af357715532d4617a3:

  batman-adv: initialize up/down values when adding a gateway (2015-08-05 00:31:47 +0200)

----------------------------------------------------------------
Included changes:
- prevent DAT from replying on behalf of local clients and confuse L2
  bridges
- fix crash on double list removal of TT objects (tt_local_entry)
- fix crash due to missing NULL checks
- initialize bw values for new GWs objects to prevent memory leak

----------------------------------------------------------------
Antonio Quartulli (1):
      batman-adv: avoid DAT to mess up LAN state

Marek Lindner (2):
      batman-adv: fix kernel crash due to missing NULL checks
      batman-adv: protect tt_local_entry from concurrent delete events

Simon Wunderlich (1):
      batman-adv: initialize up/down values when adding a gateway

 net/batman-adv/distributed-arp-table.c | 18 +++++++++++++-----
 net/batman-adv/gateway_client.c        |  2 ++
 net/batman-adv/soft-interface.c        |  3 +++
 net/batman-adv/translation-table.c     | 29 ++++++++++++++++++++++++-----
 4 files changed, 42 insertions(+), 10 deletions(-)
