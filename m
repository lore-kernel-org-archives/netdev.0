From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH v3 1/4] ARM: pxa: enhance smc91x platform data
Date: Mon, 17 Oct 2016 21:45:29 +0200
Message-ID: <1476733532-29716-2-git-send-email-robert.jarzmik@free.fr>
References: <1476733532-29716-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-am33-list@redhat.com
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Daniel Mack <daniel@zonque.org>,
        Haojian Zhuang <haojian.zhuang@gmail.com>,
        Robert Jarzmik <robert.jarzmik@free.fr>,
        Jonathan Cameron <jic23@cam.ac.uk>,
        David Howells <dhowells@redhat.com>,
        Nicolas Pitre <nico@fluxnic.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476733532-29716-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of having the smc91x driver relying on machine_is_*() calls,
provide this data through platform data, ie. idp, mainstone and
stargate.

This way, the driver doesn't need anymore machine_is_*() calls, which
wouldn't work anymore with a device-tree build.

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
---
 arch/arm/mach-pxa/idp.c       | 1 +
 arch/arm/mach-pxa/mainstone.c | 1 +
 arch/arm/mach-pxa/stargate2.c | 1 +
 include/linux/smc91x.h        | 1 +
 4 files changed, 4 insertions(+)

diff --git a/arch/arm/mach-pxa/idp.c b/arch/arm/mach-pxa/idp.c
index 66070acaa888..d1db32b1a2c6 100644
--- a/arch/arm/mach-pxa/idp.c
+++ b/arch/arm/mach-pxa/idp.c
@@ -85,6 +85,7 @@ static struct resource smc91x_resources[] = {
 static struct smc91x_platdata smc91x_platdata = {
 	.flags = SMC91X_USE_8BIT | SMC91X_USE_16BIT | SMC91X_USE_32BIT |
 		 SMC91X_USE_DMA | SMC91X_NOWAIT,
+	.pxa_u16_align4 = true,
 };
 
 static struct platform_device smc91x_device = {
diff --git a/arch/arm/mach-pxa/mainstone.c b/arch/arm/mach-pxa/mainstone.c
index 40964069a17c..a2d851a3a546 100644
--- a/arch/arm/mach-pxa/mainstone.c
+++ b/arch/arm/mach-pxa/mainstone.c
@@ -140,6 +140,7 @@ static struct resource smc91x_resources[] = {
 static struct smc91x_platdata mainstone_smc91x_info = {
 	.flags	= SMC91X_USE_8BIT | SMC91X_USE_16BIT | SMC91X_USE_32BIT |
 		  SMC91X_NOWAIT | SMC91X_USE_DMA,
+	.pxa_u16_align4 = true,
 };
 
 static struct platform_device smc91x_device = {
diff --git a/arch/arm/mach-pxa/stargate2.c b/arch/arm/mach-pxa/stargate2.c
index 702f4f14b708..7b6610e9dae4 100644
--- a/arch/arm/mach-pxa/stargate2.c
+++ b/arch/arm/mach-pxa/stargate2.c
@@ -673,6 +673,7 @@ static struct resource smc91x_resources[] = {
 static struct smc91x_platdata stargate2_smc91x_info = {
 	.flags = SMC91X_USE_8BIT | SMC91X_USE_16BIT | SMC91X_USE_32BIT
 	| SMC91X_NOWAIT | SMC91X_USE_DMA,
+	.pxa_u16_align4 = true,
 };
 
 static struct platform_device smc91x_device = {
diff --git a/include/linux/smc91x.h b/include/linux/smc91x.h
index e302c447e057..129bc674dcf5 100644
--- a/include/linux/smc91x.h
+++ b/include/linux/smc91x.h
@@ -39,6 +39,7 @@ struct smc91x_platdata {
 	unsigned long flags;
 	unsigned char leda;
 	unsigned char ledb;
+	bool pxa_u16_align4;	/* PXA buggy u16 writes on 4*n+2 addresses */
 };
 
 #endif /* __SMC91X_H__ */
-- 
2.1.4
