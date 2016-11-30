From: "ASIX_Allan [Office]" <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Subject: [PATCH] net: asix: Fix AX88772_suspend() USB vendor commands failure issues
Date: Wed, 30 Nov 2016 16:29:08 +0800
Message-ID: <00d701d24ae3$d4f4f2a0$7eded7e0$@asix.com.tw>
Reply-To: <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "'Jon Hunter'" <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
        <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>, <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
        <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>,
        <ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        <vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, <changchias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>,
        <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
        <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <vpalatin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: zh-tw
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


The change fixes AX88772_suspend() USB vendor commands failure issues.

Signed-off-by: Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Tested-by: Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Tested-by: Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>

---
--- a/drivers/net/usb/asix_devices.c	2016-11-28 05:08:04.000000000 +0800
+++ b/drivers/net/usb/asix_devices.c	2016-11-30 09:31:54.000000000 +0800
@@ -603,12 +603,12 @@ static void ax88772_suspend(struct usbne
 	u16 medium;
 
 	/* Stop MAC operation */
-	medium = asix_read_medium_status(dev, 0);
+	medium = asix_read_medium_status(dev, 1);
 	medium &= ~AX_MEDIUM_RE;
-	asix_write_medium_mode(dev, medium, 0);
+	asix_write_medium_mode(dev, medium, 1);
 
 	netdev_dbg(dev->net, "ax88772_suspend: medium=0x%04x\n",
-		   asix_read_medium_status(dev, 0));
+		   asix_read_medium_status(dev, 1));
 
 	/* Preserve BMCR for restoring */
 	priv->presvd_phy_bmcr =


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
