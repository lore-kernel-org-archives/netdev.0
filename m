From: Martin Fuzzey <mfuzzey@gmail.com>
Subject: SMC91x: forcing speed
Date: Thu, 4 Jun 2009 15:08:29 +0200
Message-ID: <ba4215e10906040608m36538458u60a7971834f26d2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nico@cam.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:56082 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653AbZFDNPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 09:15:19 -0400
Received: by ewy6 with SMTP id 6so1093029ewy.37
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2009 06:15:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am using the SMC91x driver on a based ARM board that has a hardware
problem causing 100Mbps mode not to work (even though the PHY
negotiates to that speed).
Unfortunately fixing the hardware is not an option :(

I'm currently using this simple hack to make it work:

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index fdcbaf8..95f129e 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -2022,7 +2022,9 @@ static int __devinit smc_probe(struct net_device
*dev, void __iomem *ioaddr,

        if (lp->version >= (CHIP_91100 << 4)) {
                lp->ctl_rfduplx = 1;
+#ifndef CONFIG_MACH_PKN_TGX200
                lp->ctl_rspeed = 100;
+#endif
        }

        /* Grab the IRQ */

Is there a better way of doing this that would be acceptable for mainline?
The options I can think of are :

1) platform data : (new bit in flags or new member in struct smc91x_platdata)
2) command line parameter

I prefer 1) since that lets the board specific code do it rather than
messing with bootloader parameters.

I need NFS root so setting the speed later with miitool etc is not an
option [I don't want to add an initrd just for this]

I'm happy to submit the patch if we can agree on the method and other
people may be interested or should I just stick to my current hack?

Regards,

Martin
