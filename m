From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [patch] usbnet: pegasus: endian bug in write_mii_word()
Date: Fri, 3 May 2013 09:44:20 +0300
Message-ID: <20130503064420.GA14069@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Petko Manolov <petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We're only passing the two high bits of an integer.  It works for little
endian but not for big endian.

Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 0969905..03e8a15 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -256,8 +256,9 @@ static int mdio_read(struct net_device *dev, int phy_id, int loc)
 static void mdio_write(struct net_device *dev, int phy_id, int loc, int val)
 {
 	pegasus_t *pegasus = netdev_priv(dev);
+	u16 data = val;
 
-	write_mii_word(pegasus, phy_id, loc, (__u16 *)&val);
+	write_mii_word(pegasus, phy_id, loc, &data);
 }
 
 static int read_eprom_word(pegasus_t *pegasus, __u8 index, __u16 *retdata)
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
