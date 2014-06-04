From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 0/3] Fix support for macvlan devices on top bonding
Date: Wed,  4 Jun 2014 16:23:35 -0400
Message-ID: <1401913418-31307-1-git-send-email-vyasevic@redhat.com>
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
	kaber@trash.net, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750777AbaFDUXr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 16:23:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, macvlan devices do not work well over bond interfaces.
Everything works well, untill a failover is triggered in the bond
device and then macvlan becomes unreachble untill arp entries
are flushed.   This series adds needed functionality to
handle correct notifications and update switches with mac addresses
assigned to macvlans.

The first patch simply addes IFF_UNICAST_FLT flag to bonds since they
already correctly manage the unicast filter list of the slaves, so
we might as well prevent the bond from needlessly going into promiscuous
mode.

The second patch adds notifier handler to macvlan to trigger correct
ARP notifications.

The third patch adds handling for TLB and RLB modes that use special
ETH_P_LOOPBACK type packets to teach switch about mac addresses.
It also allow ARPs for the macvlan mac addresses to be handled by
RLB mode.

Vlad Yasevich (3):
  bonding: Turn on IFF_UNICAST_FLT on bond devices
  macvlan: Support bonding events
  bonding: Support macvlans on top of tlb/rlb mode bonds

 drivers/net/bonding/bond_alb.c  | 21 ++++++++++++++++++---
 drivers/net/bonding/bond_main.c |  8 ++++----
 drivers/net/bonding/bonding.h   | 24 ++++++++++++++++++++++++
 drivers/net/macvlan.c           |  7 +++++++
 4 files changed, 53 insertions(+), 7 deletions(-)

-- 
1.9.0
