From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] natsemi: fix timing issue for reading mac from
 eeprom via dp8381x
Date: Thu, 20 Nov 2014 23:00:14 -0500 (EST)
Message-ID: <20141120.230014.1345689976107929686.davem@davemloft.net>
References: <trinity-d8a7b1cb-ed12-4c9d-ab97-aeb44e03addf-1416435970952@3capp-webde-bs23>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: devzero@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51871 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757003AbaKUEAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 23:00:20 -0500
In-Reply-To: <trinity-d8a7b1cb-ed12-4c9d-ab97-aeb44e03addf-1416435970952@3capp-webde-bs23>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Roland Kletzing" <devzero@web.de>
Date: Wed, 19 Nov 2014 23:26:11 +0100

> diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
> index b83f7c0..96f0029 100644
> --- a/drivers/net/ethernet/natsemi/natsemi.c
> +++ b/drivers/net/ethernet/natsemi/natsemi.c
> @@ -987,7 +987,7 @@ static int natsemi_probe1(struct pci_dev *pdev, const struct pci_device_id *ent)
>     The old method of using an ISA access as a delay, __SLOW_DOWN_IO__, is
>     deprecated.
>  */
> -#define eeprom_delay(ee_addr)  readl(ee_addr)
> +#define eeprom_delay(ee_addr)  readl(ee_addr);  readl(ee_addr)

Your email client has corrupted this patch, changing TAB characters
into sequences of spaces.

Also, you should not just have a macro expanding to two statements,
because now things like:

	if (x)
		eeprom_delay(addr);

doesn't do what you intended.

Either make this an inline function, or enclose the two readl()
statements inside of a "do { } while (0)"
