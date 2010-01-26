From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bonding: bond_open error return value
Date: Tue, 26 Jan 2010 01:34:15 -0800
Message-ID: <20100126013415.0120d6a9@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49980 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751913Ab0AZJe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 04:34:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The convention for API functions in kernel is to return errno value;
bond_open would return -1 if alb setup failed. The only reason that
could happen is if kmalloc() failed.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/bonding/bond_main.c	2010-01-26 01:28:18.281568331 -0800
+++ b/drivers/net/bonding/bond_main.c	2010-01-26 01:29:58.101099312 -0800
@@ -3650,7 +3650,7 @@ static int bond_open(struct net_device *
 		 */
 		if (bond_alb_initialize(bond, (bond->params.mode == BOND_MODE_ALB))) {
 			/* something went wrong - fail the open operation */
-			return -1;
+			return -ENOMEM;
 		}
 
 		INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
