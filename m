From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request: batman-adv 20150811
Date: Tue, 11 Aug 2015 18:35:38 +0200
Message-ID: <1439310948-32426-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:24321 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965202AbbHKQgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 12:36:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

this is our first batch intended for net-next.

Here you have all those non-critical fixes/changes that we couldn't
merge into the net tree as it was already too late in the release
cycle.

This is a summary of what each patch does:

- patch 1 by Sven Eckelmann is changing the way the GW metric is
computed so that the resulting operation does not make use of
divisions and also does not lead to any data type promotion. This is
a requirement for patch 2;
- patch 2 by Ruben Wisniewski is changing the type of the variable used
in the same GW metric computation as patch 1 to uint64_t so that potent=
ial
integer overflows are prevented. Thanks to Sven's patch above no 64bit
division will be involved;
- patches 3, 4, 5 and 6 by Linus L=C3=BCssing are converting plain bitw=
ise
operations on capability bits to set/clear/test_bit() in order to ensur=
e
their atomicity and prevent potential race conditions;
- patch 7, also by Linus, is making the multicast TVLV parsing routine
thread-safe in order to prevent potential race conditions upon receptio=
n
of two OGMs from the same originator at the same time;
- patch 8 by Marek Lindner prevents potential double deletions
of TT Request objects from its lists which would lead to a kernel crash=
=2E
- patch 9 by Simon Wunderlich is ensuring that no enqueued packet is le=
aked
when an interface is deactivated;
- patch 10 by Linus L=C3=BCssing is setting the network header in the s=
kb struct
right after a packet was delivered to the batman virtual interface so t=
hat
subsequent call to ip/ipv6_hdr() do not crash.


Please pull or let me know of any problem!

Thanks a lot David,
	Antonio


The following changes since commit 07a51cd3794960548627a27aae68c1446341=
db32:

  vxlan: fix fdb_dump index calculation (2015-08-10 21:15:18 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 125300dd5850a0489b4aacf06e1424a1e34eaefa=
:

  batman-adv: Fix potentially broken skb network header access (2015-08=
-11 18:11:19 +0200)

----------------------------------------------------------------
Included changes:
- avoid integer overflow in GW selection routine
- prevent race condition by making capability bit changes atomic (use
  clear/set/test_bit)
- fix synchronization issue in mcast tvlv handler
- fix crash on double list removal of TT Request objects
- fix leak by puring packets enqueued for sending upon iface removal
- ensure network header pointer is set in skb

----------------------------------------------------------------
Linus L=C3=BCssing (6):
      batman-adv: Make DAT capability changes atomic
      batman-adv: Make NC capability changes atomic
      batman-adv: Make TT capability changes atomic
      batman-adv: Make MCAST capability changes atomic
      batman-adv: Fix potential synchronization issues in mcast tvlv ha=
ndler
      batman-adv: Fix potentially broken skb network header access

Marek Lindner (1):
      batman-adv: protect tt request from double deletion

Ruben Wisniewski (1):
      batman-adv: Avoid u32 overflow during gateway select

Simon Wunderlich (1):
      batman-adv: remove broadcast packets scheduled for purged outgoin=
g if

Sven Eckelmann (1):
      batman-adv: Replace gw_reselect divisor with simple shift

 net/batman-adv/distributed-arp-table.c |  7 +--
 net/batman-adv/gateway_client.c        |  8 +---
 net/batman-adv/multicast.c             | 81 +++++++++++++++++++++++++-=
--------
 net/batman-adv/network-coding.c        |  7 +--
 net/batman-adv/originator.c            |  5 +++
 net/batman-adv/send.c                  |  3 +-
 net/batman-adv/soft-interface.c        |  7 ++-
 net/batman-adv/translation-table.c     | 17 ++++---
 net/batman-adv/types.h                 | 15 ++++---
 9 files changed, 102 insertions(+), 48 deletions(-)
