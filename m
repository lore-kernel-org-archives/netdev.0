From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: add get permanent address option
Date: Mon, 18 Oct 2010 20:52:21 +0100
Message-ID: <1287431541.2252.556.camel@achroite.uk.solarflarecom.com>
References: <20101018114139.71073a40@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:45534 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932993Ab0JRTwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 15:52:24 -0400
In-Reply-To: <20101018114139.71073a40@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-10-18 at 11:41 -0700, Stephen Hemminger wrote:
> Add command level support for showing permanent address.
> The ioctl has been around for a long time but there was
> no option to display it.
> 
> Note: MAX_ADDR_LEN is defined in netdevice.h but including
> netdevice.h leads to multiple definition errors with if.h.
[...]
> @@ -2950,6 +2961,29 @@ static int do_flash(int fd, struct ifreq *ifr)
>  	return err;
>  }
>  
> +static int do_permaddr(int fd, struct ifreq *ifr)
> +{
> +	int i, err;
> +	struct ethtool_perm_addr *epaddr;
> +
> +	epaddr = malloc(sizeof(struct ethtool_perm_addr) + MAX_ADDR_LEN);
> +	epaddr->cmd = ETHTOOL_GPERMADDR;
> +	epaddr->size = MAX_ADDR_LEN;
> +	ifr->ifr_data = (caddr_t)epaddr;
> +
> +	err = send_ioctl(fd, ifr);
> +	if (err < 0)
> +		perror("Cannot read permanent address\n");
[...]

Don't include a newline in the argument to perror().

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

