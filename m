From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Mixed PCI/ISA device name conflicts
Date: Mon, 22 Mar 2004 20:56:27 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <405F994B.6080501@pobox.com>
References: <20031222091115.42dd5f1f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031222091115.42dd5f1f.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> PCI is getting initialized before the old ISA probing code, so on mixed
> ISA/PCI systems a PCI card will get eth0 before the ISA probing starts.
> Then when the first ISA card is probed it will (unsuccessfully) try and claim
> eth0.
> 
> This fixes it by just having the ISA code skip eth0.  It relies on the convention
> that if the ioaddr is one, the device should be skipped.
> 
> Patch against net-drivers-2.5-exp
> 
> diff -Nru a/net/core/dev.c b/net/core/dev.c
> --- a/net/core/dev.c	Fri Dec 19 14:47:46 2003
> +++ b/net/core/dev.c	Fri Dec 19 14:47:46 2003
> @@ -382,6 +382,7 @@
>   *	The found settings are set for the device to be used
>   *	later in the device probing.
>   *	Returns 0 if no settings found.
> + *	        1 if device already exists
>   */
>  unsigned long netdev_boot_base(const char *prefix, int unit)
>  {
> @@ -390,6 +391,9 @@
>  	int i;
>  
>  	sprintf(name, "%s%d", prefix, unit);
> +	if (__dev_get_by_name(name))
> +		return 1;
> +
>  	for (i = 0; i < NETDEV_BOOT_SETUP_MAX; i++)
>  		if (!strcmp(name, s[i].name))
>  			return s[i].map.base_addr;


Is this patch still needed?

	Jeff
