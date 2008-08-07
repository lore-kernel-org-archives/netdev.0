From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] dm9000: Support MAC address setting through platform
 data.
Date: Thu, 07 Aug 2008 02:24:34 -0400
Message-ID: <489A9522.6090108@garzik.org>
References: <200807231741.53011.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ben Dooks <ben-linux@fluff.org>
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53843 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754461AbYHGGYi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:24:38 -0400
In-Reply-To: <200807231741.53011.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Laurent Pinchart wrote:
> The dm9000 driver reads the chip's MAC address from the attached EEPROM. When
> no EEPROM is present, or when the MAC address is invalid, it falls back to
> reading the address from the chip.
> 
> This patch lets platform code set the desired MAC address through platform
> data.
> 
> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> ---
>  drivers/net/dm9000.c   |    3 +++
>  include/linux/dm9000.h |    1 +
>  2 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index 864295e..6bc8924 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -716,6 +716,11 @@ dm9000_probe(struct platform_device *pdev)
>  	for (i = 0; i < 6; i += 2)
>  		dm9000_read_eeprom(db, i / 2, ndev->dev_addr+i);
>  
> +	if (!is_valid_ether_addr(ndev->dev_addr) && pdata != NULL) {
> +		mac_src = "platform data";
> +		memcpy(ndev->dev_addr, pdata->dev_addr, 6);
> +	}
> +
>  	if (!is_valid_ether_addr(ndev->dev_addr)) {
>  		/* try reading from mac */
>  		
> diff --git a/include/linux/dm9000.h b/include/linux/dm9000.h
> index a375046..4fb49a4 100644
> --- a/include/linux/dm9000.h
> +++ b/include/linux/dm9000.h
> @@ -26,6 +26,7 @@
>  
>  struct dm9000_plat_data {
>  	unsigned int	flags;
> +	unsigned char	dev_addr[6];

applied


