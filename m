From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request: batman-adv 2013-10-23
Date: Wed, 23 Oct 2013 18:04:47 +0200
Message-ID: <1382544303-2694-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:34155 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416Ab3JWQFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 12:05:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is another set of changes intended for net-next/linux-3.13.
(probably our last pull request for this cycle)

Patches 1 and 2 reshape two of our main data structures in a way that they can
easily be extended in the future to accommodate new routing protocols.

Patches from 3 to 9 improve our routing protocol API and its users so that all
the protocol-related code is not mixed up with the other components anymore.

Patch 10 limits the local Translation Table maximum size to a value such that it
can be fully transfered over the air if needed. This value depends on
fragmentation being enabled or not and on the mtu values.

Patch 11 makes batman-adv send a uevent in case of soft-interface destruction
while a "bat-Gateway" was configured (this informs userspace about the GW not
being available anymore).

Patches 13 and 14 enable the TT component to detect non-mesh client flag
changes at runtime (till now those flags where set upon client detection and
were not changed anymore).

Patch 16 is a generalisation of our user-to-kernel space communication (and
viceversa) used to exchange ICMP packets to send/received to/from the mesh
network. Now it can easily accommodate new ICMP packet types without breaking
the existing userspace API anymore.


Remaining patches are minor changes and cleanups.


Please pull or let me know of any problem.

Thanks a lot,
	Antonio



The following changes since commit 47d4ab91e4472723f181075c81627374ca86816c:

  macvlan: resolve ENOENT errors on creation (2013-10-22 19:22:09 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to da6b8c20a5b8c7edce95c95fa2356300691094f5:

  batman-adv: generalize batman-adv icmp packet handling (2013-10-23 17:03:47 +0200)

----------------------------------------------------------------
Included changes:
- data structure reshaping to accommodate multiple routing protocol
  implementations
- routing protocol API enhancement
- send to userspace the event "batman-adv Gateway loss" in case of soft-iface
  destruction and a "batman-adv Gateway" was configured
- improve the TT component to support and advertise runtime flag changes
- minor code refactoring
- make the ICMP kernel-to-userspace communication more generic

----------------------------------------------------------------
Antonio Quartulli (13):
      batman-adv: make struct batadv_neigh_node algorithm agnostic
      batman-adv: make struct batadv_orig_node algorithm agnostic
      batman-adv: add bat_orig_print API function
      batman-adv: add bat_neigh_cmp API function
      batman-adv: add bat_neigh_is_equiv_or_better API function
      batman-adv: adapt bonding to use the new API functions
      batman-adv: adapt the neighbor purging routine to use the new API functions
      batman-adv: provide orig_node routing API
      batman-adv: adapt the TT component to use the new API functions
      batman-adv: send GW_DEL event in case of soft-iface destruction
      batman-adv: invoke dev_get_by_index() outside of is_wifi_iface()
      batman-adv: improve the TT component to support runtime flag changes
      batman-adv: include the sync-flags when compute the global/local table CRC

Marek Lindner (1):
      batman-adv: limit local translation table max size

Simon Wunderlich (2):
      batman-adv: Start new development cycle
      batman-adv: generalize batman-adv icmp packet handling

 net/batman-adv/bat_iv_ogm.c        | 399 ++++++++++++++++++++++++++++++++-----
 net/batman-adv/gateway_client.c    |  16 +-
 net/batman-adv/hard-interface.c    |  83 ++++----
 net/batman-adv/hard-interface.h    |   2 +-
 net/batman-adv/icmp_socket.c       | 128 +++++++-----
 net/batman-adv/icmp_socket.h       |   2 +-
 net/batman-adv/main.c              |   4 +-
 net/batman-adv/main.h              |   8 +-
 net/batman-adv/network-coding.c    |   8 +-
 net/batman-adv/originator.c        | 249 ++++++-----------------
 net/batman-adv/originator.h        |   6 +-
 net/batman-adv/packet.h            |   7 +-
 net/batman-adv/routing.c           | 159 +++++++++------
 net/batman-adv/routing.h           |   3 +-
 net/batman-adv/soft-interface.c    |  12 +-
 net/batman-adv/translation-table.c | 235 +++++++++++++++++++---
 net/batman-adv/translation-table.h |   3 +-
 net/batman-adv/types.h             | 109 +++++++---
 18 files changed, 956 insertions(+), 477 deletions(-)
