From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: [RFC] [PATCH 3/3] enable IP multicast when bonding IPoIB devices
Date: Tue, 26 Sep 2006 13:18:09 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0609261317460.24189@zuben>
References: <Pine.LNX.4.64.0609261309540.24189@zuben>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:8254 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP
	id S1751094AbWIZKSK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 06:18:10 -0400
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0609261309540.24189@zuben>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>

Index: net-2.6.19/drivers/net/bonding/bond_main.c
===================================================================
--- net-2.6.19.orig/drivers/net/bonding/bond_main.c	2006-09-25 11:46:35.000000000 +0300
+++ net-2.6.19/drivers/net/bonding/bond_main.c	2006-09-26 10:54:44.000000000 +0300
@@ -128,6 +128,12 @@ MODULE_PARM_DESC(arp_interval, "arp inte
 module_param_array(arp_ip_target, charp, NULL, 0);
 MODULE_PARM_DESC(arp_ip_target, "arp targets in n.n.n.n form");

+static int bonding_dev_type    = ARPHRD_ETHER;
+static int bonding_dev_addrlen = ETH_ALEN;
+
+module_param(bonding_dev_type,    int, 0644);
+module_param(bonding_dev_addrlen, int, 0644);
+
 /*----------------------------- Global variables ----------------------------*/

 static const char * const version =
@@ -4606,7 +4612,14 @@ int bond_create(char *name, struct bond_
 		res = -ENOMEM;
 		goto out_rtnl;
 	}
-
+
+	/* XXX set the bond dev type and addr len such that the net core code
+	* (eg arp_mc_map() in net/ipv4/arp.c) would correctly process multicast
+	* groups set ***before*** the first enslaveness
+	*/
+	bond_dev->type     = bonding_dev_type;
+	bond_dev->addr_len = bonding_dev_addrlen;
+
 	/* bond_init() must be called after dev_alloc_name() (for the
 	 * /proc files), but before register_netdevice(), because we
 	 * need to set function pointers.

