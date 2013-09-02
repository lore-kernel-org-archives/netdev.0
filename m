From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 0/5] bonding: locking simplifications and cleanup
Date: Mon,  2 Sep 2013 13:51:37 +0200
Message-ID: <1378122702-28943-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22476 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754338Ab3IBLzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 07:55:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
This small patchset aims to remove some use cases of bond->lock for mutual
exclusion which will help in the RCUfication of the function users. It also
does some small style cleanups and fixes.

Patch 01 - Drops the use of bond->lock as mutual exclusion for peer
notification and relies on RTNL being held when send_peer_notif is modified
Patch 02 - trivial outdated comment removal
Patch 03 - Drops the use of bond->lock as mutual exclusion for lacp rate
update and relies on RTNL, also fixes possible races with mode change
Patch 04 - Drops read_lock in bond_fix_features because RTNL is held
Patch 05 - Drops read_lock in bond_compute_features because RTNL is held
whenever it's called

Best regards,
 Nikolay Aleksandrov

Nikolay Aleksandrov (5):
  bonding: simplify and fix peer notification
  bonding: trivial: remove outdated comment and braces
  bonding: simplify bond_3ad_update_lacp_rate and use RTNL for sync
  bonding: drop read_lock in bond_fix_features
  bonding: drop read_lock in bond_compute_features

 drivers/net/bonding/bond_3ad.c   |  8 +------
 drivers/net/bonding/bond_main.c  | 48 ++++++++++++----------------------------
 drivers/net/bonding/bond_sysfs.c |  7 +++++-
 3 files changed, 21 insertions(+), 42 deletions(-)

-- 
1.8.1.4
