From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH -net v2 0/2] bonding: fix arp_validate desync state & race
Date: Sat,  7 Sep 2013 00:00:24 +0200
Message-ID: <1378504826-18855-1-git-send-email-nikolay@redhat.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3050 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750805Ab3IFWEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Sep 2013 18:04:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,
These two patches aim to fix the possible de-sync state which the bond
can enter if we have arp_validate without arp_interval or the other way
around. They also fix a race condition between arp_validate setting and
mode changing.

Patch 01 - fixes the race condition between store_arp_validate and bond
mode change by using rtnl for sync
Patch 02 - fixes the possible de-sync state by setting/unsetting recv_probe
if arp_interval is set/unset and also if arp_validate is set/unset

v2: Fix the mode check in store_arp_validate

Best regards,
 Nikolay Aleksandrov


Nikolay Aleksandrov (2):
  bonding: fix store_arp_validate race with mode change
  bonding: fix bond_arp_rcv setting and arp validate desync state

 drivers/net/bonding/bond_main.c  |  4 ++--
 drivers/net/bonding/bond_sysfs.c | 31 +++++++++++++++++++++++++------
 drivers/net/bonding/bonding.h    |  1 +
 3 files changed, 28 insertions(+), 8 deletions(-)

-- 
1.8.1.4
