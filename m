From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] bonding: fix a memory leak in bond_arp_send_all()
Date: Fri, 25 Jul 2014 15:21:21 +0300
Message-ID: <20140725122121.GC528@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35983 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbaGYMVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 08:21:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This test is reversed so the memory is always leaked.  It's better style
to remove the test anyway.

Fixes: 3e403a77779f ('bonding: make it possible to have unlimited nested upper vlans')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 023ec36..f0f5eab 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2287,8 +2287,7 @@ found:
 		ip_rt_put(rt);
 		bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
 			      addr, tags);
-		if (!tags)
-			kfree(tags);
+		kfree(tags);
 	}
 }
 
