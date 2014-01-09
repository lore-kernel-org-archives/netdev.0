From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request: batman-adv 2014-01-09
Date: Thu,  9 Jan 2014 15:52:49 +0100
Message-ID: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:42569 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbaAIOyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 09:54:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a batch of patches intended for net-next/linux-3.14.

Here we start with patches 1, 2 and 3 that are minor cleanups:
- fix a typ0 in a header guard define
- substitute the FSF address with the URL in every file (checkpatch still
  complains about the text I used, but this is what the rest of the networking
  code is doing)
- minor optimisation of ntohl usage

Then we have patch 4 that improves the bat-GW selection feature by deselecting
the current GW on client mode deactivation. This allows userspace to get a
meaningful uevent on a further client mode reactivation.

Patches 5 and 6 are other minor refactorings:
- a function renaming (gw_deselect() -> gw_reselect()) to better reflect its
  behaviour
- remove parenthesis around return expressions

Patch 7 is yet another improvement to the bat-GW feature: now all the DHCP
packets are sent via bat-unicast messages. With this we achieves to goals:
	1) the DHCP protocol becomes even more reliable in sparse wireless mesh
	networks, where broadcast packets do not always make their way through
	2) the broadcast overhead due to DHCP packets in dense wireless networks
	is now reduced as we only use unicasts.

In the end patches from 8 to 13 implement a new feature: the Extended
Isolation (which is basically it is an extension of the already existing AP
Isolation concept).
This new mechanism allows the user to prevent communications from a generic
client A to a generic client B (located in two different point of the mesh
network) based on the value of the skb->mark field. This can be seen as a first
step towards a netfilter integration in a mesh-wide environment.
For more documentation about this new mechanism, please read [1].


Please pull or let me know of any problem!

Thanks a lot,
	Antonio

[1] http://www.open-mesh.org/projects/batman-adv/wiki/Extended-isolation



p.s. thanks for notifying me the merge of net into net-next! In this way I
avoided you to deal with some ugly merge conflicts :)



The following changes since commit 80077935cad223b292d4a03e901a953b20a36593:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next (2014-01-08 01:11:19 -0500)

are available in the git repository at:


  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 42cb0bef0176572e2e826b49d697c653eedd7fce:

  batman-adv: set the isolation mark in the skb if needed (2014-01-08 20:49:46 +0100)

----------------------------------------------------------------
Included changes:
- substitute FSF address with URL
- deselect current bat-GW when GW-client mode gets deactivated
- send every DHCP packet using bat-unicast messages when GW-client mode is
  enabled
- implement the Extended Isolation mechanism (it is an enhancement of the
  already existing batman-AP-isolation). This mechanism allows the user to drop
  packets exchanged by selected clients by using netfilter marks.
- fix typ0 in header guard
- minor code cleanups

----------------------------------------------------------------
Antonio Quartulli (13):
      batman-adv: properly rename define in distributed arp table header file
      batman-adv: don't switch byte order too often if not needed
      batman-adv: remove FSF address from GPL disclaimer
      batman-adv: deselect current GW on client mode switch off
      batman-adv: rename gw_deselect() to gw_reselect()
      batman-adv: remove parenthesis from return statements
      batman-adv: send every DHCP packet as bat-unicast
      batman-adv: add isolation_mark sysfs attribute
      batman-adv: mark a local client as isolated when needed
      batman-adv: print the new BATADV_TT_CLIENT_ISOLA flag
      batman-adv: extend the ap_isolation mechanism
      batman-adv: create helper function to get AP isolation status
      batman-adv: set the isolation mark in the skb if needed

 Documentation/ABI/testing/sysfs-class-net-mesh |   8 +
 net/batman-adv/Makefile                        |   4 +-
 net/batman-adv/bat_algo.h                      |   4 +-
 net/batman-adv/bat_iv_ogm.c                    |   4 +-
 net/batman-adv/bitarray.c                      |   4 +-
 net/batman-adv/bitarray.h                      |   4 +-
 net/batman-adv/bridge_loop_avoidance.c         |   4 +-
 net/batman-adv/bridge_loop_avoidance.h         |   4 +-
 net/batman-adv/debugfs.c                       |   4 +-
 net/batman-adv/debugfs.h                       |   4 +-
 net/batman-adv/distributed-arp-table.c         |  10 +-
 net/batman-adv/distributed-arp-table.h         |  10 +-
 net/batman-adv/fragmentation.c                 |   4 +-
 net/batman-adv/fragmentation.h                 |   4 +-
 net/batman-adv/gateway_client.c                | 215 ++++++++++++-------------
 net/batman-adv/gateway_client.h                |  10 +-
 net/batman-adv/gateway_common.c                |   6 +-
 net/batman-adv/gateway_common.h                |   4 +-
 net/batman-adv/hard-interface.c                |   4 +-
 net/batman-adv/hard-interface.h                |   4 +-
 net/batman-adv/hash.c                          |   4 +-
 net/batman-adv/hash.h                          |   4 +-
 net/batman-adv/icmp_socket.c                   |   4 +-
 net/batman-adv/icmp_socket.h                   |   4 +-
 net/batman-adv/main.c                          |  30 +++-
 net/batman-adv/main.h                          |   7 +-
 net/batman-adv/network-coding.c                |   4 +-
 net/batman-adv/network-coding.h                |   4 +-
 net/batman-adv/originator.c                    |   4 +-
 net/batman-adv/originator.h                    |   4 +-
 net/batman-adv/packet.h                        |   5 +-
 net/batman-adv/routing.c                       |  12 +-
 net/batman-adv/routing.h                       |   4 +-
 net/batman-adv/send.c                          |  20 ++-
 net/batman-adv/send.h                          |  14 +-
 net/batman-adv/soft-interface.c                | 107 +++++++-----
 net/batman-adv/soft-interface.h                |   4 +-
 net/batman-adv/sysfs.c                         |  92 ++++++++++-
 net/batman-adv/sysfs.h                         |   4 +-
 net/batman-adv/translation-table.c             |  76 ++++++---
 net/batman-adv/translation-table.h             |   8 +-
 net/batman-adv/types.h                         |  18 ++-
 42 files changed, 437 insertions(+), 311 deletions(-)
