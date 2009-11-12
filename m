From: "Figo.zhang" <figo1802@gmail.com>
Subject: Re: KS8695: problem with ethernet driver
Date: Thu, 12 Nov 2009 22:44:26 +0800
Message-ID: <1258037066.1931.8.camel@myhost>
References: <efc9214f0911160123t31d7df31tc1afcbd5129b7d86@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vincent Sanders <vince@simtec.co.uk>,
	Ben Dooks <ben@simtec.co.uk>
To: zeal <zealcook@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f180.google.com ([209.85.216.180]:41718 "EHLO
	mail-px0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809AbZKPNcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 08:32:18 -0500
Received: by pxi10 with SMTP id 10so1139825pxi.33
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 05:32:24 -0800 (PST)
In-Reply-To: <efc9214f0911160123t31d7df31tc1afcbd5129b7d86@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-11-16 at 17:23 +0800, zeal wrote:
> Hi,
> 
> I've two questions on the ks8695.
> 
> 1. We knew recently Figo.zhang has added NAPI support for ks8695 net driver.
> Thanks him. But on our ks8695 board it couldn't work well as i thought.
> We used net-next-git kernel.
> 
> IP layer cannot receive any frame from lan or wan port(s).
> 
> After dig into the driver, I found the rx interrupt occurs,
> but the corresponding status bit is not set. So it won't go into napi
> schedule block.

would like to add debug information at ks8695_rx_irq() to see if the
interrupt function can work and the status value? in line 443, add :
printk(KERN_EMERG "rx status = 0x%x\n", status);

> 
>         if (status & mask_bit) {
>                 if (napi_schedule_prep(&ksp->napi)) {
>                         /*disable rx interrupt*/
>                         status &= ~mask_bit;
>                         writel(status , KS8695_IRQ_VA + KS8695_INTEN);
>                         __napi_schedule(&ksp->napi);
>                 }
>         }
> 
> Does anybody tested this NAPI driver succeeded before? If so it maybe
> hardware issue.
> 
> 2. It's a extend topic about ks8695. Does the cpu port can tell the
> source port (i.e. lan port ID)
> when it receive a frame from LAN ports? I think a smart switch need
> know where the frame come from
> and then decide where it to go. And many switch-chip in this way.
> The manual can't help me at all as i've done according to it.
> 
> Any hint is appreciated.
> 


