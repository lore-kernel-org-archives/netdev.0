From: Antonio Quartulli <ordex@autistici.org>
Subject: pull request: batman-adv 2013-01-19
Date: Sat, 19 Jan 2013 21:27:46 +0800
Message-ID: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:57436 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012Ab3ASN32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 08:29:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

here is our second patchset intended for net-next/linux-3.9.
In this batch you have some struct refactoring and a great kernel doc
improvement by Marek Lindner. In patch 10/13 you have the random32() function
renaming proposed by Akinobu Mita.

In 11/13 instead you have a behavioural change brought by Simon Wunderlich which
is modifying the way a batman-adv virtual interface is unregistered in order to
prevent a possible deadlock involving rntl_lock and s_active. We have
already been discussing about this problem and its possible solution on the
netdev mailing list.
The rest is just clean up work.

Please pull or let me know if there is any problem.

Thanks a lot,
	Antonio



The following changes since commit 1ad759d8479b4b28f2a6c874d380066cf987b341:

  ipv6: remove unneeded check to pskb_may_pull in ipip6_rcv (2013-01-18 14:43:51 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 5ac2a177298e1f245aa54cce4030842f3abe5aea:

  batman-adv: Start new development cycle (2013-01-19 21:18:13 +0800)

----------------------------------------------------------------
Included changes:
- sysfs removal postponement during interface un-registration
- random32() function renaming
- struct refactoring
- kernel doc improvement
- deleyed_work initialisation clean up work
- copyright year and internal version number update
- kernel doc improvement

----------------------------------------------------------------
Akinobu Mita (1):
      batman-adv: rename random32() to prandom_u32()

Antonio Quartulli (3):
      batman-adv: a delayed_work has to be initialised once
      batman-adv: update copyright years
      batman-adv: Start new development cycle

Marek Lindner (8):
      batman-adv: align kernel doc properly
      batman-adv: mark debug_log struct as bat_priv only struct
      batman-adv: group tt type definitions together
      batman-adv: rename batadv_if_list_entry struct to make clear it is used by vis
      batman-adv: rename batadv_recvlist_node struct to make clear it is used by vis
      batman-adv: rename batadv_backbone_gw struct to make clear it is used by bla
      batman-adv: rename batadv_claim struct to make clear it is used by bla
      batman-adv: kernel doc for types.h

Simon Wunderlich (1):
      batman-adv: postpone sysfs removal when unregistering

 net/batman-adv/bat_algo.h              |   2 +-
 net/batman-adv/bat_iv_ogm.c            |   6 +-
 net/batman-adv/bitarray.c              |   2 +-
 net/batman-adv/bitarray.h              |   2 +-
 net/batman-adv/bridge_loop_avoidance.c | 113 ++++---
 net/batman-adv/bridge_loop_avoidance.h |   2 +-
 net/batman-adv/debugfs.c               |  15 +-
 net/batman-adv/debugfs.h               |   2 +-
 net/batman-adv/distributed-arp-table.c |   2 +-
 net/batman-adv/distributed-arp-table.h |   2 +-
 net/batman-adv/gateway_client.c        |   2 +-
 net/batman-adv/gateway_client.h        |   2 +-
 net/batman-adv/gateway_common.c        |   2 +-
 net/batman-adv/gateway_common.h        |   2 +-
 net/batman-adv/hard-interface.c        |  26 +-
 net/batman-adv/hard-interface.h        |   2 +-
 net/batman-adv/hash.c                  |   2 +-
 net/batman-adv/hash.h                  |   2 +-
 net/batman-adv/icmp_socket.c           |   2 +-
 net/batman-adv/icmp_socket.h           |   2 +-
 net/batman-adv/main.c                  |   2 +-
 net/batman-adv/main.h                  |   6 +-
 net/batman-adv/originator.c            |  19 +-
 net/batman-adv/originator.h            |   2 +-
 net/batman-adv/packet.h                |   2 +-
 net/batman-adv/ring_buffer.c           |   2 +-
 net/batman-adv/ring_buffer.h           |   2 +-
 net/batman-adv/routing.c               |   2 +-
 net/batman-adv/routing.h               |   2 +-
 net/batman-adv/send.c                  |   7 +-
 net/batman-adv/send.h                  |   2 +-
 net/batman-adv/soft-interface.c        |  34 +-
 net/batman-adv/soft-interface.h        |   2 +-
 net/batman-adv/sysfs.c                 |   2 +-
 net/batman-adv/sysfs.h                 |   2 +-
 net/batman-adv/translation-table.c     |  16 +-
 net/batman-adv/translation-table.h     |   2 +-
 net/batman-adv/types.h                 | 568 ++++++++++++++++++++++++++-------
 net/batman-adv/unicast.c               |   2 +-
 net/batman-adv/unicast.h               |   2 +-
 net/batman-adv/vis.c                   |  36 +--
 net/batman-adv/vis.h                   |   2 +-
 42 files changed, 641 insertions(+), 267 deletions(-)
