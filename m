From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net V2 0/2] bonding:add aging mechanism to rlb table
Date: Thu, 22 Mar 2012 16:37:49 +0800
Message-ID: <cover.1332405098.git.panweiping3@gmail.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net, linux-kernel@vger.kernel.org,
	Weiping Pan <panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:64251 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752629Ab2CVIn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 04:43:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac(jbohac@suse.cz) found that once an IP address is recorded in the
rlb hash table, it stays there indefinitely. If this IP address is migrated
to a different host in the network, bonding still sends out ARP packets
that poison other systems' ARP caches with invalid information.

There are some attempts to fix this problem,
http://marc.info/?l=linux-netdev&m=133036407906892&w=4
http://marc.info/?l=linux-netdev&m=133057427414043&w=4

But they did not fix the root cause of the problem, that rlb table does not
have a aging mechanism, the entry is deemed valid for ever unless it is
replaced.

In this patchset I want to add aging mechanism to rlb table.

Assume RLB_MONITOR_DELAY is 2 seconds and RLB_WORK_COUNTER_TIMES is 3,
and we can tune them.

Every 6 seconds bonding will make all entries invalid.
Every 2 seconds, bonding will send arp requests to its all
clients, then if it receives corresponding arp reply, bonding will deem that
this entry is valid.
And we give a entry 3 opportunities to survive in 6 seconds.

V2:
add cover letter

Weiping Pan (2):
  bonding:delete rlb entry if bond's ip is deleted
  bonding:delete rlb entry at regular intervals

 drivers/net/bonding/bond_alb.c  |  130 ++++++++++++++++++++++++++++++++++++---
 drivers/net/bonding/bond_alb.h  |    9 +++
 drivers/net/bonding/bond_main.c |   11 +++-
 3 files changed, 138 insertions(+), 12 deletions(-)

-- 
1.7.4
