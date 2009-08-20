From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC][PATCH][v4] ethtool: Add a new ethtool option to flash a
	firmware image from the specified file to a device.
Date: Thu, 20 Aug 2009 18:27:59 +0100
Message-ID: <1250789279.2779.5.camel@achroite>
References: <20090820171635.GA20213@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:39270 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753096AbZHTR2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 13:28:04 -0400
In-Reply-To: <20090820171635.GA20213@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-08-20 at 22:46 +0530, Ajit Khaparde wrote:
> This patch adds a new "-f" option to the ethtool utility
> to flash a firmware image specified by a file, to a network device.
> The filename is passed to the network driver which will flash the image
> on the chip using the request_firmware path.
[...]
> @@ -304,6 +309,9 @@ static int rx_fhash_get = 0;
>  static int rx_fhash_set = 0;
>  static u32 rx_fhash_val = 0;
>  static int rx_fhash_changed = 0;
> +static char flash_file[ETHTOOL_FLASH_MAX_FILENAME];

It would be much simpler to make this a pointer...

> +static int flash = -1;
> +static int flash_region = 0;
>  static enum {
>  	ONLINE=0,
>  	OFFLINE,
[...]
> @@ -516,6 +525,10 @@ static void parse_cmdline(int argc, char **argp)
>  				if (phys_id_time < 0)
>  					show_usage(1);
>  				break;
> +			} else if (mode == MODE_FLASHDEV) {
> +				sprintf(flash_file, "%s", argp[i]);

...and to change this to "flash_file = argp[i];"...

> +				flash = 1;
> +				break;
>  			}
>  			/* fallthrough */
>  		default:
[...]
> @@ -2398,6 +2419,38 @@ static int do_grxclass(int fd, struct ifreq *ifr)
>  	return 0;
>  }
>  
> +static int do_flash(int fd, struct ifreq *ifr)
> +{
> +	struct ethtool_flash efl;
> +	int err;
> +
> +	if (flash < 0) {
> +		fprintf(stdout, "Missing filename argument\n");
> +		show_usage(1);
> +		return 98;
> +	}
> +
> +	if (strlen(flash_file) > ETHTOOL_FLASH_MAX_FILENAME - 1) {
> +		fprintf(stdout, "Filename too long\n");
> +		return 99;
> +	}
[...]

...and then this length check would work properly.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

