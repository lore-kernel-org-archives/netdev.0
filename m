From: Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>
Subject: [PATCH v3 3/4] net: smc91x: take into account half-word workaround
Date: Mon, 17 Oct 2016 21:45:31 +0200
Message-ID: <1476733532-29716-4-git-send-email-robert.jarzmik@free.fr>
References: <1476733532-29716-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-am33-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        Haojian Zhuang <haojian.zhuang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>,
        Jonathan Cameron <jic23-KWPb1pKIrIJaa/9Udqfwiw@public.gmane.org>,
        David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Nicolas Pitre <nico-vtqb6HGKxmzR7s880joybQ@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476733532-29716-1-git-send-email-robert.jarzmik-GANU6spQydw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

For device-tree builds, platforms such as mainstone, idp and stargate2
must have their u16 writes all aligned on 32 bit boundaries. This is
already enabled in platform data builds, and this patch adds it to
device-tree builds.

Signed-off-by: Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>
---
Since v1: rename dt property to pxa-u16-align4
---
 drivers/net/ethernet/smsc/smc91x.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 705d99b2d947..65077c77082a 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2326,6 +2326,8 @@ static int smc_drv_probe(struct platform_device *pdev)
 		if (!device_property_read_u32(&pdev->dev, "reg-shift",
 					      &val))
 			lp->io_shift = val;
+		lp->cfg.pxa_u16_align4 =
+			device_property_read_bool(&pdev->dev, "pxa-u16-align4");
 	}
 #endif
 
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
