From: Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>
Subject: [PATCH 2/3] net: smc91x: take into account half-word workaround
Date: Mon,  3 Oct 2016 11:05:52 +0200
Message-ID: <1475485553-18747-2-git-send-email-robert.jarzmik@free.fr>
References: <1475485553-18747-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Nicolas Pitre <nico-vtqb6HGKxmzR7s880joybQ@public.gmane.org>,
        Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1475485553-18747-1-git-send-email-robert.jarzmik-GANU6spQydw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

For device-tree builds, platforms such as mainstone, idp and stargate2
must have their u16 writes all aligned on 32 bit boundaries. This is
already enabled in platform data builds, and this patch adds it to
device-tree builds.

Signed-off-by: Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>
---
 drivers/net/ethernet/smsc/smc91x.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index b1f74e06d98e..b081d5ca88ce 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2323,6 +2323,8 @@ static int smc_drv_probe(struct platform_device *pdev)
 		if (!device_property_read_u32(&pdev->dev, "reg-shift",
 					      &val))
 			lp->io_shift = val;
+		lp->half_word_align4 =
+			device_property_read_bool(&pdev->dev, "reg-u16-align4");
 	}
 #endif
 
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
