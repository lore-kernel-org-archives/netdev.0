From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Tue, 30 Sep 2008 22:59:35 +0200
Message-ID: <48E29337.2080400@free.fr>
References: <48DF7D51.1010507@free.fr> <20080929123036.GA16954@ff.dom.local> <48E1F417.7080304@free.fr> <20080930101030.GA6290@ff.dom.local> <20080930111733.GB6290@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g19.free.fr ([212.27.42.27]:60547 "EHLO smtp1-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983AbYI3U7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2008 16:59:43 -0400
In-Reply-To: <20080930111733.GB6290@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek,

Yes I am using n2kpci/8390 driver.
The second patch seems to have removed the inconsistent lock state.
But the kernel panic still occured systematically.
However I did not catch netconsole messages since the patch prevented 
transmission to remote console via ethernet.

Before the machine rebooted I only noted the following information at 
the bottom of the local console page :

EIP: [<.....>] datagram_poll + 0xe9/0xf0

Does it help ?

Bernard


Jarek Poplawski wrote:
> On Tue, Sep 30, 2008 at 10:10:30AM +0000, Jarek Poplawski wrote:
>> On Tue, Sep 30, 2008 at 11:40:39AM +0200, Bernard Pidoux F6BVP wrote:
>>> Hi Jarek,
>> Hi Bernard,
>>
>>> Yes this is a vanilla kernel, which makes it interesting to debug.
>>> I forgot to Cc: Ralf and put it now on copy of this message.
>>> Thank you for the patch I applied.
>>> Collected data includes both events I already reported, first the  
>>> inconsistent lock state,
>> I guess this netconsole is on ne2k_pci/8390 driver?
> 
> If so, try this patch, please.
> 
> Jarek P.
> 
> ---
> 
>  drivers/net/lib8390.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
> index 00d59ab..f80dcc1 100644
> --- a/drivers/net/lib8390.c
> +++ b/drivers/net/lib8390.c
> @@ -530,9 +530,9 @@ static irqreturn_t __ei_interrupt(int irq, void *dev_id)
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  static void __ei_poll(struct net_device *dev)
>  {
> -	disable_irq_lockdep(dev->irq);
> +	disable_irq(dev->irq);
>  	__ei_interrupt(dev->irq, dev);
> -	enable_irq_lockdep(dev->irq);
> +	enable_irq(dev->irq);
>  }
>  #endif
>  
> 
> 
