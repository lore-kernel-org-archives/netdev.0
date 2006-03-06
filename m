From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: de2104x: interrupts before interrupt handler is registered
Date: Mon, 6 Mar 2006 22:17:45 +0100
Message-ID: <20060306211745.GD15728@electric-eye.fr.zoreil.com>
References: <20060305180757.GA22121@deprecation.cyrius.com> <20060305185948.GA24765@electric-eye.fr.zoreil.com> <20060306143512.GI23669@deprecation.cyrius.com> <20060306191706.GA6947@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752436AbWCFVT6@vger.kernel.org>
To: Martin Michlmayr <tbm@cyrius.com>
Content-Disposition: inline
In-Reply-To: <20060306191706.GA6947@deprecation.cyrius.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Martin Michlmayr <tbm@cyrius.com> :
[...]
> There's another interrupt related bug in the driver, though.  I
> sometimes get a kernel panic when rsycing several 100 megs of data
> across the LAN.  A picture showing the call trace can be found at
> http://www.cyrius.com/tmp/de2104x_panic.jpg

Not sure about this one, but...

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index d7fb3ff..49235e2 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -1455,6 +1455,8 @@ static void de_tx_timeout (struct net_de
 	synchronize_irq(dev->irq);
 	de_clean_rings(de);
 
+	de_init_rings(de);
+
 	de_init_hw(de);
 	
 	netif_wake_queue(dev);
