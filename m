From: "Remy Bohmer" <linux@bohmer.net>
Subject: Re: DM9000_IRQ_FLAGS
Date: Tue, 11 Dec 2007 21:31:03 +0100
Message-ID: <3efb10970712111231r29f9fba1l3528d805d1009c52@mail.gmail.com>
References: <20071211191823.GD15295@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Daniel Mack" <daniel@caiaq.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:37995 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753548AbXLKUbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 15:31:06 -0500
Received: by py-out-1112.google.com with SMTP id u77so544751pyb
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 12:31:05 -0800 (PST)
In-Reply-To: <20071211191823.GD15295@buzzloop.caiaq.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Daniel,

This controller is also used on many other boards, like the e.g. Atmel
AT91sam9261-ek board. On that board on both the rising _and_ falling
edge an interrupt is generated.

I can test tomorrow if this patch leaves this board in tact, but
should the board-specific code not add this flag if it is required ?
By modifying this driver you will interfere the behavior of other
boards, and I do not know if there any level triggered types used.


Kind Regards,

Remy Bohmer


2007/12/11, Daniel Mack <daniel@caiaq.de>:
> Hi,
>
> on Toradex' Colibri, a PXA270 based board with a DM9000 ethernet
> controller, this driver won't work due to unsuitable DM9000_IRQ_FLAGS.
> If I understood the code behind request_irq() correctly, it's not
> recommended to register an IRQ without any of the IRQT_* flags set.
>
> Is there any concerns about applying the patch below?
>
> Best regards,
> Daniel
>
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index 3286d2a..6a20a54 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -66,6 +66,7 @@
>  #include <linux/dm9000.h>
>  #include <linux/delay.h>
>  #include <linux/platform_device.h>
> +#include <linux/irq.h>
>
>  #include <asm/delay.h>
>  #include <asm/irq.h>
> @@ -113,7 +114,7 @@
>  #define writesl        outsl
>  #define DM9000_IRQ_FLAGS       (IRQF_SHARED | IRQF_TRIGGER_HIGH)
>  #else
> -#define DM9000_IRQ_FLAGS       IRQF_SHARED
> +#define DM9000_IRQ_FLAGS       (IRQF_SHARED | IRQT_RISING)
>  #endif
>
>  /*
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
