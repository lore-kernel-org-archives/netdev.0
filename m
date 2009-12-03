From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [patch]reset_resume for cdc-ether
Date: Thu, 3 Dec 2009 11:02:56 +0100
Message-ID: <200912031102.56903.oliver@neukum.org>
References: <200911241159.02098.oliver@neukum.org> <20091202.221627.133392199.davem@davemloft.net> <20091202.222254.61468873.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091202.222254.61468873.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Donnerstag, 3. Dezember 2009 07:22:54 schrieb David Miller:
> > I'm going to apply this patch and the USB autosuspend one too.
> 
> Actually, neither patch applies to net-next-2.6
> 
> Oliver can you respin your changes and add a proper signoff
> to the autosuspend patch?

Hi,

here's reset_resume() again.

	Regards
		Oliver

Signed-off-by: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>

--

commit 0cf82130a576e01d516fcd81a0a6976ab7c49c23
Author: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Date:   Thu Dec 3 10:59:20 2009 +0100

    cdc-ether:imlement reset_resume()
    
    Normal resume can do double duty as reset_resume() for this driver
    as it keeps no state in the device
    
    Signed-off-by: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index b9493ef..50b8aa9 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -585,6 +585,7 @@ static struct usb_driver cdc_driver = {
 	.disconnect =	usbnet_disconnect,
 	.suspend =	usbnet_suspend,
 	.resume =	usbnet_resume,
+	.reset_resume =	usbnet_resume,
 	.supports_autosuspend = 1,
 };
 
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
