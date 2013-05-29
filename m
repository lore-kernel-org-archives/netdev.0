From: Antonio Quartulli <ordex@autistici.org>
Subject: pull request: batman-adv 2013-05-29
Date: Wed, 29 May 2013 02:59:25 +0200
Message-ID: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:43797 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757898Ab3E2BBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 21:01:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is our pull request intended for net-next/linux-3.11.

The only real behavioural change in this batch is the broadcast overhea=
d
reduction on non-wireless interfaces brought by Matthias Schiffer.

The rest is made up by code cleanups and refactoring.

Two highlights on the refactoring are the introduction of
netdev_alloc_skb_ip_align() to avoid to deal with NET_IP_ALIGN manually=
 and the
introduction of the eth_hdr() wherever it was possible in order to impr=
ove
readability.


Please pull or let me know of any problem.

Thanks a lot,
	Antonio



The following changes since commit 06ecf24bdf2b7afc6c8fd13de6dba2a96dd3=
31b6:

  net: Fix build warnings after mac_header and transport_header became =
__u16. (2013-05-28 13:15:50 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 6715fd3f0538e805b6a769d66823ec16b8b647ac=
:

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
      batman-adv: don't initialise batman_iv private members in hard-in=
terface.c
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
      batman-adv: do not print orig nodes without nc neighbors on nc ta=
ble print

Martin Hundeb=C3=B8ll (1):
      batman-adv: Move call to batadv_nc_skb_forward() from routing.c t=
o send.c

Matthias Schiffer (2):
      batman-adv: split batadv_is_wifi_iface() into two functions
      batman-adv: send each broadcast only once on non-wireless interfa=
ces

Simon Wunderlich (1):
      batman-adv: Start new development cycle

 net/batman-adv/Makefile                |   1 -
 net/batman-adv/bat_iv_ogm.c            | 122 ++++++++++++++++++++++++-=
--------
 net/batman-adv/bridge_loop_avoidance.c |  94 +++++++++++++------------
 net/batman-adv/bridge_loop_avoidance.h |  12 ++--
 net/batman-adv/distributed-arp-table.c |  82 +++++++++++-----------
 net/batman-adv/hard-interface.c        |  96 +++++++++++++++----------=
-
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
