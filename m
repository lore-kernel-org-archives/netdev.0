From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH v2 2/3] net: smc91x: take into account half-word workaround
Date: Sat, 15 Oct 2016 21:27:49 +0200
Message-ID: <1476559670-25056-3-git-send-email-robert.jarzmik@free.fr>
References: <1476559670-25056-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Robert Jarzmik <robert.jarzmik@free.fr>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Nicolas Pitre <nico@fluxnic.net>,
        Russell King - ARM Linux <linux@armlinux.org.uk>,
        Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476559670-25056-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For device-tree builds, platforms such as mainstone, idp and stargate2
must have their u16 writes all aligned on 32 bit boundaries. This is
already enabled in platform data builds, and this patch adds it to
device-tree builds.

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
---
Since v1: rename dt property to pxa-u16-align4
---
 drivers/net/ethernet/smsc/smc91x.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 5658c2b28ec8..c14676805d06 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2329,6 +2329,8 @@ static int smc_drv_probe(struct platform_device *pdev)
 		if (!device_property_read_u32(&pdev->dev, "reg-shift",
 					      &val))
 			lp->io_shift = val;
+		lp->half_word_align4 =
+			device_property_read_bool(&pdev->dev, "pxa-u16-align4");
 	}
 #endif
 
-- 
2.1.4
