From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: CRC endianess problem on DGE-510T
Date: Fri, 10 Jun 2011 13:35:01 +0100
Message-ID: <1307709301.22348.594.camel@localhost>
References: <4DF1CFC2.5080101@gaisler.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Hellstrom <daniel@gaisler.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:15348 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755770Ab1FJMfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 08:35:04 -0400
In-Reply-To: <4DF1CFC2.5080101@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-10 at 10:03 +0200, Daniel Hellstrom wrote:
> Hello,
> 
> I'm having problems with the PCI network board D-LINK DGE-510T on 
> SPARC32/LEON. The CRC calculated by ether_crc_le() does not match the 
> CRC, however after swapping the result it matches. This is the same 
> behaviour with the 3 boards I have. After applying the patch below 
> everything works.
> 
> Does anyone know if this is a correct patch or has had similar problems 
> on big endian machines?

No idea about this hardware, but it looks reasonable - the contents of
the EEPROM are treated as being in little-endian order, except when
reading the CRC for comparison.

> Daniel
> 
> 
> 
> 
> From: Daniel Hellstrom <daniel@gaisler.com>
> Date: Wed, 6 Apr 2011 15:01:44 +0200
> [PATCH] dl2k: EEPROM CRC calculation wrong endianess on bigendian machine
> 
> Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
> ---
>  drivers/net/dl2k.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
> index c445457..4bbbd7b 100644
> --- a/drivers/net/dl2k.c
> +++ b/drivers/net/dl2k.c
> @@ -346,7 +346,7 @@ parse_eeprom (struct net_device *dev)
>         if (np->pdev->vendor == PCI_VENDOR_ID_DLINK) {  /* D-Link Only */
>                 /* Check CRC */
>                 crc = ~ether_crc_le (256 - 4, sromdata);
> -               if (psrom->crc != crc) {
> +               if (psrom->crc != cpu_to_le32(crc)) {q

q?

Ben.

>                         printk (KERN_ERR "%s: EEPROM data CRC error.\n",
>                                         dev->name);
>                         return -1;
> --
> 1.5.4
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

