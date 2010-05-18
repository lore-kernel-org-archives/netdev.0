From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] bonding: remove redundant checks from
 bonding_store_slaves
Date: Tue, 18 May 2010 14:09:45 +0200
Message-ID: <20100518120944.GA2878@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28702 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757371Ab0ERMJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 08:09:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove checks that duplicates similar checks in bond_enslave.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 4e84cfc..6c44c07 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -243,7 +243,7 @@ static ssize_t bonding_store_slaves(struct device *d,
 
 	if (command[0] == '+') {
 
-		/* Got a slave name in ifname.  Is it already in the list? */
+		/* Got a slave name in ifname. */
 
 		dev = __dev_get_by_name(dev_net(bond->dev), ifname);
 		if (!dev) {
@@ -253,24 +253,6 @@ static ssize_t bonding_store_slaves(struct device *d,
 			goto out;
 		}
 
-		if (dev->flags & IFF_UP) {
-			pr_err("%s: Error: Unable to enslave %s because it is already up.\n",
-			       bond->dev->name, dev->name);
-			ret = -EPERM;
-			goto out;
-		}
-
-		read_lock(&bond->lock);
-		bond_for_each_slave(bond, slave, i)
-			if (slave->dev == dev) {
-				pr_err("%s: Interface %s is already enslaved!\n",
-				       bond->dev->name, ifname);
-				ret = -EPERM;
-				read_unlock(&bond->lock);
-				goto out;
-			}
-		read_unlock(&bond->lock);
-
 		pr_info("%s: Adding slave %s.\n", bond->dev->name, ifname);
 
 		/* If this is the first slave, then we need to set
