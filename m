From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 6/5] sis900 printk audit
Date: Sun, 23 Jan 2005 10:10:49 +0100
Message-ID: <20050123091049.GE31816@gateway.milesteg.arr>
References: <20050122214657.18649.66345@localhost.localdomain> <20050122214659.18649.83119@localhost.localdomain> <20050122222618.GA24461@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="IS0zKkzwUGydFO0o"
Cc: Jeff Garzik <jgarzik@pobox.com>, NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20050122222618.GA24461@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jan 22, 2005 at 11:26:18PM +0100, Francois Romieu wrote:
> Daniele Venzano <webvenza@libero.it> :
> > -			printk(KERN_INFO "Cannot allocate mem for struct mii_phy\n");
> > +			printk(KERN_WARNING "Cannot allocate mem for struct mii_phy\n");
> 
> -> printk(KERN_WARNING "%s: Cannot allocate mem for struct mii_phy\n", ...) ?
> 
> Btw it may make sense to use pci_name() instead of the name associated with
> the struct net_device until it is known for sure that the net_device will not
> be removed due to a failure of the probe() method. 

Attached a patch on top of the previous ones.

It only fixes the missing prefix. I understand that pci_name could be a
better choice here, but I want to see what other drivers are doing in
their probe() before changing policy.

Signed-off-by: Daniele Venzano <webvenza@linero.it>

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org


--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sis900_c_89.diff"

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 88)
+++ b/drivers/net/sis900.c	(revision 89)
@@ -576,7 +576,7 @@
 		}
 		
 		if ((mii_phy = kmalloc(sizeof(struct mii_phy), GFP_KERNEL)) == NULL) {
-			printk(KERN_WARNING "Cannot allocate mem for struct mii_phy\n");
+			printk(KERN_WARNING "%s: Cannot allocate mem for struct mii_phy\n", net_dev->name);
 			mii_phy = sis_priv->first_mii;
 			while (mii_phy) {
 				struct mii_phy *phy;

--IS0zKkzwUGydFO0o--
