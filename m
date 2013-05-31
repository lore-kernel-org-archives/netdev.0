From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH v2 net 0/6] net/core, bonding: dev_uc_sync fixes, bonding update
Date: Fri, 31 May 2013 14:57:25 -0700
Message-ID: <1370037451-29466-1-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:37691 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753129Ab3EaV5v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 May 2013 17:57:51 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 31 May 2013 17:57:50 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 72938C90042
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 17:57:47 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4VLvlCq59965686
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 17:57:47 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4VLvkWt025448
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 18:57:46 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	This patch set includes 6 patches: four fixes to the dev_mc_sync /
dev_mc_unsync system; and two patches to bonding, one to utilize the sync
/ unsync functions, and another minor fix.

	A brief description of each patch:

	1. uninitialized variable in __hw_addr_create_ex

	2. __hw_addr_unsync_one does not work because "from" addresses
		aren't marked as "synced."

	3. __hw_addr_sync_one as called by __hw_addr_sync_multiple will
		not remove references properly

	4. dev_mc_sync_multiple doesn't call the _multiple helper function

	5. Convert bonding to use dev_{mc,uc}_sync / unsync

	6. Disallow changes of bonding MAC if fail_over_mac is set to
		"follow".

V2: 

	Rebased to net

	Patch 5 is changed: fixed a logic error in bond_set_rx_mode.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
