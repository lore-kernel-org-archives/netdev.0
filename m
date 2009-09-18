From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] bonding: set primary param via sysfs
Date: Fri, 18 Sep 2009 14:13:22 +0200
Message-ID: <20090918121321.GB2801@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45070 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752589AbZIRMNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2009 08:13:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Primary module parameter passed to bonding is pernament. That means if you
release the primary slave and enslave it again, it becomes the primary slave
again. But if you set primary slave via sysfs, the primary slave is only set
once and it's not remembered in bond->params structure. Therefore the setting is
lost after releasing the primary slave. This simple one-liner fixes this.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 6044e12..ff449de 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1182,6 +1182,7 @@ static ssize_t bonding_store_primary(struct device *d,
 				       ": %s: Setting %s as primary slave.\n",
 				       bond->dev->name, slave->dev->name);
 				bond->primary_slave = slave;
+				strcpy(bond->params.primary, slave->dev->name);
 				bond_select_active_slave(bond);
 				goto out;
 			}
