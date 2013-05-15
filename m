From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH 0/4] bonding: race and inconsistency fixes
Date: Wed, 15 May 2013 14:32:38 +0200
Message-ID: <1368621162-6807-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34237 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758125Ab3EOMgN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 08:36:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
 In patch 1/4 a race condition while changing the bonding mode through
 sysfs is fixed. Since no synchronization method is used it can race
 with different functions resulting in different impacts. RTNL is used
 to sync with the most important and dangerous events.
 Patch 2/4 is trivial and improves the debugging output by changing %x
 format to %pI4 for IPv4 addresses in a few pr_debug() calls.
 Patch 3/4 fixes an inconsistent arp_targets state where we have 0 entry
 between (or in the beginning) the valid entries that were obtained which
 is hard to diagnose otherwise.
 Patch 4/4 fixes multiple instances of a race condition which is because of
 calls to bond_3ad_get_active_agg_info without any locking, and since it 
 traverses the slave list this can easily result in NULL ptr dereference or
 use of freed memory.

Best regards,
 Nikolay Aleksandrov

Nikolay Aleksandrov (4):
  bonding: fix set mode race conditions
  bonding: replace %x with %pI4 for IPv4 addresses
  bonding: arp_ip_count and arp_targets can be wrong
  bonding: fix multiple 3ad mode sysfs race conditions

 drivers/net/bonding/bond_main.c  | 25 +++++++++++--------------
 drivers/net/bonding/bond_sysfs.c | 25 ++++++++++++++++++++-----
 2 files changed, 31 insertions(+), 19 deletions(-)

-- 
1.8.1.4
