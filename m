From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] dl2k: EEPROM CRC calculation wrong endianess on
 bigendian machine
Date: Fri, 10 Jun 2011 14:49:11 +0100
Message-ID: <1307713751.22348.602.camel@localhost>
References: <1307711777-12119-1-git-send-email-daniel@gaisler.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Hellstrom <daniel@gaisler.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:20677 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932136Ab1FJNtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 09:49:15 -0400
In-Reply-To: <1307711777-12119-1-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-10 at 15:16 +0200, Daniel Hellstrom wrote:
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
>  	if (np->pdev->vendor == PCI_VENDOR_ID_DLINK) {	/* D-Link Only */
>  		/* Check CRC */
>  		crc = ~ether_crc_le (256 - 4, sromdata);
> -		if (psrom->crc != crc) {
> +		if (psrom->crc != cpu_to_le32(crc)) {q

You still have a rogue 'q' there.

Ben.

>  			printk (KERN_ERR "%s: EEPROM data CRC error.\n",
>  					dev->name);
>  			return -1;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

