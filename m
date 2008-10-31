From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 1/3] bonding: fix miimon failure counter
Date: Thu, 30 Oct 2008 17:41:14 -0700
Message-ID: <1225413676-13579-2-git-send-email-fubar@us.ibm.com>
References: <1225413676-13579-1-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:37564 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754698AbYJaAlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 20:41:19 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id m9V0f5hN009116
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 18:41:05 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9V0fImb034836
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 18:41:18 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9V0fI74014911
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 18:41:18 -0600
In-Reply-To: <1225413676-13579-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During the rework of the mii monitor for:

commit f0c76d61779b153dbfb955db3f144c62d02173c2
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Wed Jul 2 18:21:58 2008 -0700

    bonding: refactor mii monitor

	I left out the increment of the link failure counter.  This
patch corrects that omission.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 832739f..85de1d0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2376,6 +2376,9 @@ static void bond_miimon_commit(struct bonding *bond)
 			continue;
 
 		case BOND_LINK_DOWN:
+			if (slave->link_failure_count < UINT_MAX)
+				slave->link_failure_count++;
+
 			slave->link = BOND_LINK_DOWN;
 
 			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP ||
-- 
1.6.0.2

