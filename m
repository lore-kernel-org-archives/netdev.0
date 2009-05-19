From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bc47xx : fix ssb irq setup
Date: Tue, 19 May 2009 15:19:58 +0200
Message-ID: <200905191519.59193.mb@bu3sch.de>
References: <4A11DBD4.7070706@free.fr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	Daniel Mueller <daniel@danm.de>
To: matthieu castet <castet.matthieu@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:51221 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752884AbZESNVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 09:21:19 -0400
In-Reply-To: <4A11DBD4.7070706@free.fr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 19 May 2009 00:06:12 matthieu castet wrote:
> Hi,
> 
> the current ssb irq setup (in ssb_mipscore_init) have some problem :
> it configure some device on some irq without checking that the irq is 
> not taken by an other device.
> 
> For example in my case PCI host is on irq 0 and IPSEC on irq 3.
> The current code :
> - store in dev->irq that IPSEC irq is 3+2
> - do a set_irq 0->3 on PCI host
> 
> But now IPSEC irq is not routed anymore to the mips code and dev->irq is 
> wrong. This cause problem described in [1].
> 
> This patch try to solve the problem by making set_irq configure the 
> device we want to take the irq on the shared irq0.
> The previous example become :
> - store in dev->irq that IPSEC irq is 3+2
> - do a set_irq 0->3 on PCI host :
>    - irq 3 is already taken by IPSEC. do a set_irq 3->0 on IPSEC
> 
> 
> I also added some code to print the irq configuration before and after 
> irq setup to allow easier debugging. And I add extra checking in 
> ssb_mips_irq to report device without irq or device with not routed irq.
> 
> 
> [1] http://www.danm.de/files/src/bcm5365p/REPORTED_DEVICES
> 
> Signed-off-by: Matthieu CASTET <castet.matthieu@free.fr>
> 

If this works on all devices, I'm OK with this. Please submit to linville@tuxdriver.com
You can add my ack.

-- 
Greetings, Michael.
