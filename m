From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [Linux-ATM-General] [PATCH] firmware: convert Ambassador ATM
	driver to request_firmware()
Date: Mon, 30 Jun 2008 14:09:22 +0100
Message-ID: <1214831362.10393.340.camel@pmac.infradead.org>
References: <200806301259.m5UCxewW022114@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:44558 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761740AbYF3NJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 09:09:25 -0400
In-Reply-To: <200806301259.m5UCxewW022114@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-06-30 at 08:59 -0400, Chas Williams (CONTRACTOR) wrote:
> In message <1214818473.10393.337.camel@pmac.infradead.org>,David Woodhouse writ
> es:
> >A couple of comments though... it looks like you forgot to add
> >MODULE_FIRMWARE(). And shouldn't 'fw_data' in
> >fore200e_load_and_start_firmware() be a (__le32 *) not a (u32 *)?
> 
> this look ok:
> 
> 
> diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
> index d5c1bbf..91710d4 100644
> --- a/drivers/atm/fore200e.c
> +++ b/drivers/atm/fore200e.c
> @@ -2562,7 +2562,8 @@ fore200e_load_and_start_fw(struct fore200e* fore200e)
>      const struct firmware *firmware;
>      struct device *device;
>      struct fw_header *fw_header;
> -    u32 *fw_data, fw_size;
> +    __le32 *fw_data;
> +    u32 fw_size;
>      u32 __iomem *load_addr;
>      char buf[48];
>      int err = -ENODEV;
> @@ -2582,7 +2583,7 @@ fore200e_load_and_start_fw(struct fore200e* fore200e)
>  	return err;
>      }
>  
> -    fw_data = (u32 *) firmware->data;
> +    fw_data = (__le32 *) firmware->data;

Actually, it should probably be 'const' too.

>      fw_size = firmware->size / sizeof(u32);
>      fw_header = (struct fw_header *) firmware->data;
>      load_addr = fore200e->virt_base + le32_to_cpu(fw_header->load_offset);
> @@ -3199,6 +3200,7 @@ static const struct fore200e_bus fore200e_bus[] = {
>      {}
>  };
>  
> -#ifdef MODULE_LICENSE
>  MODULE_LICENSE("GPL");
> -#endif

#ifdef CONFIG_SBUS
> +MODULE_FIRMWARE("sba200e.bin");
#ifdef CONFIG_PCI
#ifdef __LITTLE_ENDIAN
> +MODULE_FIRMWARE("pca200e.bin");
#else /* big-endian */
> +MODULE_FIRMWARE("pca200e_ecd.bin");
#endif
#endif

And wasn't it sba200e_ecd.bin ? 

-- 
dwmw2

