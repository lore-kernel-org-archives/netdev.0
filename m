From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request: batman-adv 20150609
Date: Tue,  9 Jun 2015 12:50:13 +0200
Message-ID: <1433847020-1427-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:36552 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751025AbbFIKwX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 06:52:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is our last batch of patches intended for net-next.

You have 4 patches from Sven Eckelmann, most notably: 1/7 changes
our hash implementation to use the Jenkins one provided by the kernel;
4/7 reorganizes the way we include headers so that each .c file has
all it requires without relying on any fancy including order.

Then there are three patches from me: 2/7 is slightly changing the
macros we use to handle sysfs files to make them more flexible for
future uses; 3/7 is extending the "routing protocol API" so that new
implementations can have more control over
the neigh_node internal structures; 7/7 ensures that all the per-VLAN
internal structures are updated when the MAC address is changed by the
user.

Please pull if everything is fine!

Thanks a lot,
	Antonio

The following changes since commit d691f9e8d4405c334aa10d556e73c8bf44cb0e01:

  bpf: allow programs to write to certain skb fields (2015-06-07 02:01:33 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 94d1dd87316fdb7a403a2750e13ec839fd2fadea:

  batman-adv: change the MAC of each VLAN upon ndo_set_mac_address (2015-06-07 17:07:20 +0200)

----------------------------------------------------------------
Included changes:
- use common Jenkins hash instead of private implementation
- extend internal routing API
- properly re-arrange header files inclusion
- clarify precedence between '&' and '?'
- remove unused ethhdr variable in batadv_gw_dhcp_recipient_get()
- ensure per-VLAN structs are updated upon MAC change

----------------------------------------------------------------
Antonio Quartulli (3):
      batman-adv: split name from variable for uint mesh attributes
      batman-adv: add bat_neigh_free API
      batman-adv: change the MAC of each VLAN upon ndo_set_mac_address

Sven Eckelmann (4):
      batman-adv: Use common Jenkins Hash implementation
      batman-adv: Add required includes to all files
      batman-adv: Clarify calculation precedence for '&' and '?'
      batman-adv: Remove unused post-VLAN ethhdr in batadv_gw_dhcp_recipient_get

 net/batman-adv/bat_iv_ogm.c            | 44 ++++++++++++++---
 net/batman-adv/bitarray.c              |  4 +-
 net/batman-adv/bitarray.h              |  6 +++
 net/batman-adv/bridge_loop_avoidance.c | 54 +++++++++++++--------
 net/batman-adv/bridge_loop_avoidance.h | 10 ++++
 net/batman-adv/debugfs.c               | 37 +++++++++++---
 net/batman-adv/debugfs.h               |  7 +++
 net/batman-adv/distributed-arp-table.c | 45 ++++++++++++++---
 net/batman-adv/distributed-arp-table.h | 13 +++--
 net/batman-adv/fragmentation.c         | 22 +++++++--
 net/batman-adv/fragmentation.h         |  9 ++++
 net/batman-adv/gateway_client.c        | 39 ++++++++++-----
 net/batman-adv/gateway_client.h        |  8 +++
 net/batman-adv/gateway_common.c        | 11 ++++-
 net/batman-adv/gateway_common.h        |  7 +++
 net/batman-adv/hard-interface.c        | 38 ++++++++++-----
 net/batman-adv/hard-interface.h        | 11 +++++
 net/batman-adv/hash.c                  |  6 ++-
 net/batman-adv/hash.h                  | 31 ++++--------
 net/batman-adv/icmp_socket.c           | 33 +++++++++++--
 net/batman-adv/icmp_socket.h           |  7 +++
 net/batman-adv/main.c                  | 56 ++++++++++++++-------
 net/batman-adv/main.h                  | 30 ++++++------
 net/batman-adv/multicast.c             | 29 +++++++++--
 net/batman-adv/multicast.h             |  6 +++
 net/batman-adv/network-coding.c        | 47 +++++++++++++-----
 net/batman-adv/network-coding.h        | 13 +++++
 net/batman-adv/originator.c            | 34 ++++++++++---
 net/batman-adv/originator.h            | 26 +++++-----
 net/batman-adv/packet.h                |  3 ++
 net/batman-adv/routing.c               | 36 ++++++++++----
 net/batman-adv/routing.h               | 10 ++++
 net/batman-adv/send.c                  | 36 ++++++++++----
 net/batman-adv/send.h                  | 13 +++++
 net/batman-adv/soft-interface.c        | 66 ++++++++++++++++++-------
 net/batman-adv/soft-interface.h        | 11 +++++
 net/batman-adv/sysfs.c                 | 60 +++++++++++++++--------
 net/batman-adv/sysfs.h                 | 10 ++++
 net/batman-adv/translation-table.c     | 89 +++++++++++++++++++++-------------
 net/batman-adv/translation-table.h     |  9 ++++
 net/batman-adv/types.h                 | 22 ++++++++-
 41 files changed, 784 insertions(+), 264 deletions(-)
