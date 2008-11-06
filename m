From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 6/7] drivers/net/sfc/falcon.c: fix min() warnings
Date: Thu, 06 Nov 2008 00:39:12 -0500
Message-ID: <49128300.1000602@garzik.org>
References: <200810292122.m9TLMHts020208@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	jgarzik@redhat.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39867 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750899AbYKFFjR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 00:39:17 -0500
In-Reply-To: <200810292122.m9TLMHts020208@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> drivers/net/sfc/falcon.c: In function 'falcon_spi_write_limit':
> drivers/net/sfc/falcon.c:1679: warning: comparison of distinct pointer types lacks a cast
> drivers/net/sfc/falcon.c: In function 'falcon_spi_read':
> drivers/net/sfc/falcon.c:1720: warning: comparison of distinct pointer types lacks a cast
> 
> Driver seems rather confused about types.  Try to help it.
> 
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> Cc: Jeff Garzik <jgarzik@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/sfc/falcon.c |    9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff -puN drivers/net/sfc/falcon.c~drivers-net-sfc-falconc-fix-min-warnings drivers/net/sfc/falcon.c
> --- a/drivers/net/sfc/falcon.c~drivers-net-sfc-falconc-fix-min-warnings
> +++ a/drivers/net/sfc/falcon.c
> @@ -1685,8 +1685,8 @@ static int falcon_spi_cmd(const struct e
>  	return 0;
>  }
>  
> -static unsigned int
> -falcon_spi_write_limit(const struct efx_spi_device *spi, unsigned int start)
> +static size_t
> +falcon_spi_write_limit(const struct efx_spi_device *spi, size_t start)
>  {
>  	return min(FALCON_SPI_MAX_LEN,
>  		   (spi->block_size - (start & (spi->block_size - 1))));
> @@ -1729,8 +1729,7 @@ int falcon_spi_read(const struct efx_spi
>  	int rc = 0;
>  
>  	while (pos < len) {
> -		block_len = min((unsigned int)len - pos,
> -				FALCON_SPI_MAX_LEN);
> +		block_len = min(len - pos, FALCON_SPI_MAX_LEN);
>  
>  		command = efx_spi_munge_command(spi, SPI_READ, start + pos);
>  		rc = falcon_spi_cmd(spi, command, start + pos, NULL,
> @@ -1764,7 +1763,7 @@ int falcon_spi_write(const struct efx_sp
>  		if (rc)
>  			break;
>  
> -		block_len = min((unsigned int)len - pos,
> +		block_len = min(len - pos,
>  				falcon_spi_write_limit(spi, start + pos));

I would prefer min_t()...


