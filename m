From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 0/5] net: better lockdep annotations
Date: Thu,  9 Jun 2016 07:45:10 -0700
Message-ID: <1465483515-10821-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Ahern <dsa@cumulusnetworks.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34240 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbcFIOpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 10:45:20 -0400
Received: by mail-pa0-f47.google.com with SMTP id bz2so13487237pad.1
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 07:45:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduction of qdisc->running seqcount added lockdep false positives.

While chasing the bug, it came to me that we had a lot of copies of the
same stuff in virtual drivers.

This patch series has the qdisc->running fix (considers that a trylock
is attempted in lockdep terminology), and adds a generic helper so
that we no longer have to patch many virtual drivers when a new per-device
or per-qdisc lock is added.

Thanks to David Ahern for reporting the issue and testing my patches :)


Eric Dumazet (5):
  net: sched: fix qdisc->running lockdep annotations
  net: add netdev_lockdep_set_classes() helper
  net: vrf: call netdev_lockdep_set_classes()
  net: macvlan: call netdev_lockdep_set_classes()
  net: ipvlan: call netdev_lockdep_set_classes()

 drivers/net/bonding/bond_main.c  | 24 +-----------------------
 drivers/net/ipvlan/ipvlan_main.c | 22 +---------------------
 drivers/net/macvlan.c            | 11 +----------
 drivers/net/ppp/ppp_generic.c    |  6 +-----
 drivers/net/team/team.c          | 21 +--------------------
 drivers/net/vrf.c                |  2 +-
 include/linux/netdevice.h        | 17 +++++++++++++++++
 include/net/sch_generic.h        |  6 +++++-
 net/bluetooth/6lowpan.c          | 15 +--------------
 net/ieee802154/6lowpan/core.c    | 16 +---------------
 net/l2tp/l2tp_eth.c              |  6 +-----
 net/sched/sch_generic.c          |  4 ++--
 12 files changed, 33 insertions(+), 117 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
