From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/8][BONDING]: Some BUGs and deadlocks fixes and a bit of
 concomitant cleanups.
Date: Tue, 29 Apr 2008 18:51:32 +0400
Message-ID: <481735F4.30909@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58825 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754738AbYD2PJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 11:09:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay, Dave.

While looking at the bonding driver I found four bugs visible with
the unaided eye. Here are the fixes, but I also cleaned up some
places, I just couldn't come by. If you consider those cleanups to
be for next merge window, just kick me and I'll resubmit this set
without them.

Found BUGs summary:
1. Bad error path in bond_create - the registered device should
   not be released with free_netdev;
2. Specifying the 'bond%d' name when creating a new device results
   in a new device with literally 'bond%d' name, not bond<digit>
   like for other drivers;
3. Lost unlock of rtnl and bonding_rwsem in bonding_store_bonds;
4. Deadlock between bonding_store_bonds and bond_destroy_sysfs
   on module unload.

The clean ups are
1. Minor alloc_netdev consolidation after fix #2
2. Redundant 3rd argument for bond_create;
3. Unneeded _safe list iterations in some places;
4. Unneeded list_empty checks in some places.

Details in patches.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
