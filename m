From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 1/1] Fix default phy selection after initialization
Date: Wed,  9 Mar 2005 09:26:57 +0100 (CET)
Message-ID: <20050309082657.14465.18016@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; charset="us-ascii";
	boundary="===============1810774141=="
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com, jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a MIME message, see the first attachment for the text
and the second for the patch
--===============1810774141==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit



Previous patch correct only 99% of the time, the default phy can change during
normal operation, but the mii_info struct wosn't updated.
With the attached patch it is (to be applied on top of previous).

For the locking issue it seems that not only sis900_timer is affected. Mii
access is scattered all over the driver without locking, so I think there
is need of a lot more work.



Signed-off-by: Daniele Venzano <webvenza@libero.it>


--===============1810774141==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 98)
+++ b/drivers/net/sis900.c	(revision 99)
@@ -514,8 +514,6 @@ static int __devinit sis900_probe(struct
 		goto err_out_unregister;
 	}
 
-	sis_priv->mii_info.phy_id = sis_priv->cur_phy;
-
 	/* save our host bridge revision */
 	dev = pci_get_device(PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_630, NULL);
 	if (dev) {
@@ -725,6 +723,8 @@ static u16 sis900_default_phy(struct net
 					net_dev->name,sis_priv->cur_phy);
 	}
 	
+	sis_priv->mii_info.phy_id = sis_priv->cur_phy;
+
 	status = mdio_read(net_dev, sis_priv->cur_phy, MII_CONTROL);
 	status &= (~MII_CNTL_ISOLATE);
 

--===============1810774141==--
