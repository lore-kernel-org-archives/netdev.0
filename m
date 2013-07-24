From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 3/3 net-next] bond: cleanup netpoll code
Date: Wed, 24 Jul 2013 11:53:57 -0700
Message-ID: <20130724115357.4d4bddcb@nehalam.linuxnetplumber.net>
References: <20130724115141.63bba894@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@resnulli.us>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:60815 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605Ab3GXSyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 14:54:11 -0400
Received: by mail-pb0-f42.google.com with SMTP id un1so10103027pbc.29
        for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 11:54:10 -0700 (PDT)
In-Reply-To: <20130724115141.63bba894@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This started out with fixing a sparse warning, then I realized that
the wrapper function bond_netpoll_info could just be removed
by rolling it into the enable code.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/bonding/bond_main.c	2013-07-24 08:34:05.229987883 -0700
+++ b/drivers/net/bonding/bond_main.c	2013-07-24 08:34:10.917925434 -0700
@@ -1254,12 +1254,6 @@ static int bond_netpoll_setup(struct net
 	read_unlock(&bond->lock);
 	return err;
 }
-
-static struct netpoll_info *bond_netpoll_info(struct bonding *bond)
-{
-	return bond->dev->npinfo;
-}
-
 #else
 static inline int slave_enable_netpoll(struct slave *slave)
 {
@@ -1804,7 +1798,7 @@ int bond_enslave(struct net_device *bond
 	bond_set_carrier(bond);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	slave_dev->npinfo = bond_netpoll_info(bond);
+	slave_dev->npinfo = bond->dev->npinfo;
 	if (slave_dev->npinfo) {
 		if (slave_enable_netpoll(new_slave)) {
 			read_unlock(&bond->lock);
