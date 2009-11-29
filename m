From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tulip : kernel BUG in tulip_up/tulip_resume
Date: Sun, 29 Nov 2009 01:17:10 +0100
Message-ID: <20091129001710.GA4055@ami.dom.local>
References: <20091108223305.GA21072@frolo.macqel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: grundler@parisc-linux.org, kyle@mcmartin.ca,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe De Muyter <phdm@macqel.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:41044 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674AbZK2ARN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 19:17:13 -0500
Content-Disposition: inline
In-Reply-To: <20091108223305.GA21072@frolo.macqel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Philippe De Muyter wrote, On 11/08/2009 11:33 PM:

> Hello,
> 
> I have just installed 2.6.31 (from opensuse 11.2) one a tulip-equipped
> computer and I get the following error message from the kernel :
> 
> [ 2495.526390] ------------[ cut here ]------------
> [ 2495.526390] kernel BUG at /usr/src/packages/BUILD/kernel-default-2.6.31.5/linux-2.6.31/include/linux/netdevice.h:439!
> [ 2495.526390] invalid opcode: 0000 [#1] SMP 
...
> This comes from a BUG_ON in napi_enable in netdevice.h.
> 
> napi_enable itself is called by tulip_up as such :
> 
> #ifdef CONFIG_TULIP_NAPI
> 	napi_enable(&tp->napi);
> #endif
> 
> At first reading, a matching napi_disable is called in tulip_down.
> 
> Does someone know what could be wrong and have a fix or should I look myself ?

Don't know, guess only...

Jarek P.
---

 drivers/net/tulip/tulip_core.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 0df983b..6b1456c 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1787,11 +1787,11 @@ static int tulip_resume(struct pci_dev *pdev)
 		return retval;
 	}
 
-	netif_device_attach(dev);
-
 	if (netif_running(dev))
 		tulip_up(dev);
 
+	netif_device_attach(dev);
+
 	return 0;
 }
 
