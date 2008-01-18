From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 4/7] bonding: release slaves when master removed via sysfs
Date: Thu, 17 Jan 2008 16:25:00 -0800
Message-ID: <12006159102124-git-send-email-fubar@us.ibm.com>
References: <12006159033257-git-send-email-fubar@us.ibm.com>
 <12006159063217-git-send-email-fubar@us.ibm.com>
 <12006159071917-git-send-email-fubar@us.ibm.com>
 <12006159081875-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:59743 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752843AbYARAZO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 19:25:14 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0I0PCJA018138
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:12 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0I0PCT8198224
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:12 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0I0PBDR022453
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:12 -0500
In-Reply-To: <12006159081875-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Add a call to bond_release_all in the bonding netdev event
handler for the master.  This releases the slaves for the case of, e.g.,
"echo -bond0 > /sys/class/net/bonding_masters", which otherwise will spin
forever waiting for references to be released.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 77d004d..3ede0a2 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3401,9 +3401,7 @@ static int bond_master_netdev_event(unsigned long event, struct net_device *bond
 	case NETDEV_CHANGENAME:
 		return bond_event_changename(event_bond);
 	case NETDEV_UNREGISTER:
-		/*
-		 * TODO: remove a bond from the list?
-		 */
+		bond_release_all(event_bond->dev);
 		break;
 	default:
 		break;
-- 
1.5.3.4.206.g58ba4-dirty

