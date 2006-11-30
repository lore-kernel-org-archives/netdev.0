From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: [RFC] [PATCH V2 3/3] enable IP multicast for bonding IPoIB devices
 - allow not UP enslavement
Date: Thu, 30 Nov 2006 12:58:35 +0200 (IST)
Message-ID: <Pine.LNX.4.64.0611301257520.26156@zuben>
References: <Pine.LNX.4.64.0611301256130.26156@zuben>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: openib-general@openib.org, Roland Dreier <rdreier@cisco.com>,
	Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:20955 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP id S933603AbWK3K6g
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 05:58:36 -0500
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0611301256130.26156@zuben>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>

Index: net-2.6.20/drivers/net/bonding/bond_sysfs.c
===================================================================
--- net-2.6.20.orig/drivers/net/bonding/bond_sysfs.c	2006-11-30 10:45:53.000000000 +0200
+++ net-2.6.20/drivers/net/bonding/bond_sysfs.c	2006-11-30 10:48:13.000000000 +0200
@@ -265,11 +265,9 @@ static ssize_t bonding_store_slaves(stru

 	/* Quick sanity check -- is the bond interface up? */
 	if (!(bond->dev->flags & IFF_UP)) {
-		printk(KERN_ERR DRV_NAME
-		       ": %s: Unable to update slaves because interface is down.\n",
+		printk(KERN_WARNING DRV_NAME
+		       ": %s: doing slave updates when interface is down.\n",
 		       bond->dev->name);
-		ret = -EPERM;
-		goto out;
 	}

 	/* Note:  We can't hold bond->lock here, as bond_create grabs it. */
Index: net-2.6.20/drivers/net/bonding/bond_main.c
===================================================================
--- net-2.6.20.orig/drivers/net/bonding/bond_main.c	2006-11-30 10:46:57.000000000 +0200
+++ net-2.6.20/drivers/net/bonding/bond_main.c	2006-11-30 10:48:13.000000000 +0200
@@ -1298,8 +1298,8 @@ int bond_enslave(struct net_device *bond

 	/* bond must be initialized by bond_open() before enslaving */
 	if (!(bond_dev->flags & IFF_UP)) {
-		dprintk("Error, master_dev is not up\n");
-		return -EPERM;
+		printk(KERN_WARNING DRV_NAME
+			" %s: master_dev is not up in bond_enslave\n", bond_dev->name);
 	}

 	/* already enslaved */

