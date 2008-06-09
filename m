From: <samuel@sortiz.org>
Subject: Re: [patch, v2.6.26-rc5] net/irda build fix: mcs7780
Date: Mon, 09 Jun 2008 11:26:37 +0200
Message-ID: <47304c8330b37ab2677d72f8c8adbe12@localhost>
References: <20080604.170123.234927220.davem@davemloft.net> <20080609082257.GA15282@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 25.mail-out.ovh.net ([91.121.27.228]:58776 "HELO
	25.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756218AbYFIJdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 05:33:19 -0400
In-Reply-To: <20080609082257.GA15282@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 9 Jun 2008 10:22:57 +0200, Ingo Molnar <mingo@elte.hu> wrote:

> 

> -tip testing found the following build error:

> 

>   drivers/built-in.o: In function `mcs_receive_irq':

>   mcs7780.c:(.text+0x4e429): undefined reference to `crc32_le'

>   drivers/built-in.o: In function `mcs_hard_xmit':

>   mcs7780.c:(.text+0x4e9af): undefined reference to `crc32_le'

> 

> with:

> 

>   http://redhat.com/~mingo/misc/config-Sun_Jun__8_22_56_14_CEST_2008.bad

> 

> the reason is a missing enablement of the CRC32 library in the Kconfig.

> 

> Signed-off-by: Ingo Molnar <mingo@elte.hu>

Many thanks Ingo.



Dave, I can take it with my next IrDA patch set. But since it's a build

failure, you may want to take it immediatly, it's up to you.

In the latter case:



Signed-off-by: Samuel Ortiz <samuel@sortiz.org>



> ---

>  drivers/net/irda/Kconfig |    1 +

>  1 file changed, 1 insertion(+)

> 

> Index: linux/drivers/net/irda/Kconfig

> ===================================================================

> --- linux.orig/drivers/net/irda/Kconfig

> +++ linux/drivers/net/irda/Kconfig

> @@ -329,6 +329,7 @@ config PXA_FICP

>  config MCS_FIR

>  	tristate "MosChip MCS7780 IrDA-USB dongle"

>  	depends on IRDA && USB && EXPERIMENTAL

> +	select CRC32

>  	help

>  	  Say Y or M here if you want to build support for the MosChip

>  	  MCS7780 IrDA-USB bridge device driver.

> --

> To unsubscribe from this list: send the line "unsubscribe netdev" in

> the body of a message to majordomo@vger.kernel.org

> More majordomo info at  http://vger.kernel.org/majordomo-info.html

