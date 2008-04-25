From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Fri, 25 Apr 2008 15:31:47 +0300
Message-ID: <4811CF33.8040007@teltonika.lt>
References: <20080417214719.GF17664@kroah.com> <480BE815.2000409@teltonika.lt> <480CB8C2.9090902@teltonika.lt> <480DA2CA.8090705@teltonika.lt> <480DED38.3080900@teltonika.lt> <480F3C41.10908@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040205020408050802060207"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <480F3C41.10908-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040205020408050802060207
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Incremental patch.
- don't reset rx_packets stats when telling device "up".

TODO:
- figure out what should be MTU value. Currently it is set
   to 1500-14. I guess that 14 here means eth header size, but
   this has no logical explanation...
- do we really need ethtool support? It always reports that
   link is up... The only useful information is driver name,
   version and USB path... Is it worth it?

--------------040205020408050802060207
Content-Type: text/x-patch;
 name="hso_reset_rx.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_reset_rx.patch"

--- linux-2.6-hso-my/drivers/net/usb/hso.c.orig	2008-04-23 16:24:30.000000000 +0300
+++ linux-2.6-hso-my/drivers/net/usb/hso.c	2008-04-25 15:12:48.000000000 +0300
@@ -693,8 +693,7 @@ static int hso_net_open(struct net_devic
 		dev_err(&net->dev, "No net device !\n");
 		return -ENODEV;
 	}
-	/* reset read counter. */
-	odev->net->stats.rx_packets = 0;
+
 	odev->skb_tx_buf = NULL;
 
 	/* setup environment */

--------------040205020408050802060207--

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
