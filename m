From: Patrick McHardy <kaber@trash.net>
Subject: bonding: fix device leak on error in bond_create()
Date: Fri, 26 Feb 2010 16:35:52 +0100
Message-ID: <4B87EA58.7090601@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050707090204020706060302"
Cc: Jay Vosburgh <fubar@us.ibm.com>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58244 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965167Ab0BZPfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 10:35:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050707090204020706060302
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------050707090204020706060302
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit f357a5caa0ca29b74811a0fc08efb5ae4aade959
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Feb 25 20:21:10 2010 +0100

    bonding: fix device leak on error in bond_create()
    
    When the register_netdevice() call fails, the newly allocated device is
    not freed.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1787e3c..430c022 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4946,6 +4946,8 @@ int bond_create(struct net *net, const char *name)
 	}
 
 	res = register_netdevice(bond_dev);
+	if (res < 0)
+		goto out_netdev;
 
 out:
 	rtnl_unlock();

--------------050707090204020706060302--
