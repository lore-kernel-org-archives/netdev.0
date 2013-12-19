From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request [net]: batman-adv 2013-12-19
Date: Thu, 19 Dec 2013 01:15:26 +0100
Message-ID: <1387412132-889-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:19352 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738Ab3LSARy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 19:17:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request intended for net.

Patch 1 is fixing a bug that is present in the batman-adv code since a while.
The bug prevents a batman-adv encapsulated packet from being correctly
processed by "Netfilter Bridge" twice. In particular a packet that
first enters a bridge with the batman-adv header and then enters another bridge
after the header has been removed is improperly processed. The problem is due to
the skb->nf_bridge member not being cleaned when the batman-adv header is
removed.
This patch takes care of properly releasing the nf_bridge field at the right
time (like all the other tunneling protocol do).

** Please, enqueue this patch for stable.


Patches from 2 to 6 take care of reshaping the packet layout a little bit to
make sure that all the structures we use for sending messages have size multiple
of 4 (or 2 when pack(2) is used).
This solves the problem raised by Russel King about the static checks failure
when compiling the module on the ARM architecture.



Please pull or let me know of any problem.


Thank you,
	Antonio


The following changes since commit 58a4782449c5882f61882396ef18cc34c7dc1269:

  ipv6: sit: update mtu check to take care of gso packets (2013-12-18 17:55:24 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to 128cfa6a586154581ce1b891baf929810117a82a:

  batman-adv: fix alignment for batadv_tvlv_tt_change (2013-12-19 00:27:24 +0100)

----------------------------------------------------------------
Included changes:

- release skb->nf_bridge when removing the batman-adv header
  from an incoming packet. This prevents netfilter bridge
  from being fooled when the same packet enters a bridge
  twice (or more): the first time within the batman-adv
  header and the second time without.

- adjust the packet layout to prevent any architecture from
  adding padding bytes. All the structs sent over the wire
  now have size multiple of 4bytes (unless pack(2) is used).

----------------------------------------------------------------
Antonio Quartulli (3):
      batman-adv: free nf_bridge member on locally delivered skb
      batman-adv: fix size of batadv_icmp_header
      batman-adv: fix alignment for batadv_tvlv_tt_change

Simon Wunderlich (3):
      batman-adv: fix alignment for batadv_coded_packet
      batman-adv: fix header alignment by unrolling batadv_header
      batman-adv: fix size of batadv_bla_claim_dst

 net/batman-adv/bat_iv_ogm.c            |  36 +++++-----
 net/batman-adv/distributed-arp-table.c |   6 +-
 net/batman-adv/fragmentation.c         |   8 +--
 net/batman-adv/icmp_socket.c           |   6 +-
 net/batman-adv/main.c                  |  16 ++---
 net/batman-adv/network-coding.c        |  22 +++---
 net/batman-adv/packet.h                | 124 +++++++++++++++++++++++++--------
 net/batman-adv/routing.c               |  30 ++++----
 net/batman-adv/send.c                  |  10 +--
 net/batman-adv/soft-interface.c        |  19 +++--
 net/batman-adv/soft-interface.h        |  16 +++++
 net/batman-adv/translation-table.c     |   6 +-
 12 files changed, 195 insertions(+), 104 deletions(-)
