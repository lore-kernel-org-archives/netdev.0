From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tulip : kernel BUG in tulip_up/tulip_resume
Date: Sun, 29 Nov 2009 12:36:59 +0100
Message-ID: <20091129113659.GA2971@ami.dom.local>
References: <20091108223305.GA21072@frolo.macqel>
 <20091129001710.GA4055@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: grundler@parisc-linux.org, kyle@mcmartin.ca,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe De Muyter <phdm@macqel.be>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754300AbZK2LhU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091129001710.GA4055@ami.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 29, 2009 at 01:17:10AM +0100, Jarek Poplawski wrote:
> Philippe De Muyter wrote, On 11/08/2009 11:33 PM:
> > Does someone know what could be wrong and have a fix or should I look myself ?
> 
> Don't know, guess only...

...And maybe a second guess btw. (to try together or separate).

Jarek P.
---

diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 6b2330e..fd32601 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1749,9 +1749,9 @@ static int tulip_suspend (struct pci_dev *pdev, pm_message_t state)
 	if (!netif_running(dev))
 		goto save_state;
 
+	netif_device_detach(dev);
 	tulip_down(dev);
 
-	netif_device_detach(dev);
 	free_irq(dev->irq, dev);
 
 save_state:
