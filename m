From: Joe Perches <joe@perches.com>
Subject: Re: tulip_stop_rxtx() failed (CSR5 0xf0260000 CSR6 0xb3862002) on
 DEC Alpha Personal Workstation 433au
Date: Mon, 05 Apr 2010 10:36:22 -0700
Message-ID: <1270488982.31062.28.camel@Joe-Laptop.home>
References: <20100405171318.GA18915@physik.fu-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1340 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755840Ab0DERgY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 13:36:24 -0400
In-Reply-To: <20100405171318.GA18915@physik.fu-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-04-05 at 19:13 +0200, Adrian Glaubitz wrote:
> Hi guys,
> 
> I installed Debian unstable on an old digital workstation "DEC Digital
> Personal Workstation 433au" (Miata) which has an on-board tulip
> network controller. I'm not really using that network controller but
> an off-board intel e1000 controller. However, I found that the tulip
> driver produces a lot of noise in the message log, the following
> message is repated periodically and spams the whole message log:
> 
> 0000:00:03.0: tulip_stop_rxtx() failed (CSR5 0xf0260000 CSR6 0xb3862002)
> 
> Do you think this is related to the fact that no cable is connected to
> the network controller?

Probably something is trying periodically to open the device.
Maybe this helps reduce the message log noise:

Signed-off-by: Joe Perches <joe@perches.com>
---
diff --git a/drivers/net/tulip/tulip.h b/drivers/net/tulip/tulip.h
index 0afa2d4..8c675aa 100644
--- a/drivers/net/tulip/tulip.h
+++ b/drivers/net/tulip/tulip.h
@@ -515,12 +515,11 @@ static inline void tulip_stop_rxtx(struct tulip_private *tp)
 		while (--i && (ioread32(ioaddr + CSR5) & (CSR5_TS|CSR5_RS)))
 			udelay(10);
 
-		if (!i)
-			printk(KERN_DEBUG "%s: tulip_stop_rxtx() failed"
-					" (CSR5 0x%x CSR6 0x%x)\n",
-					pci_name(tp->pdev),
-					ioread32(ioaddr + CSR5),
-					ioread32(ioaddr + CSR6));
+		if (!i && tulip_debug > 1)
+			printk(KERN_DEBUG "%s: tulip_stop_rxtx() failed (CSR5 0x%x CSR6 0x%x)\n",
+			       pci_name(tp->pdev),
+			       ioread32(ioaddr + CSR5),
+			       ioread32(ioaddr + CSR6));
 	}
 }
 


