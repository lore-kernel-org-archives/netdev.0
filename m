From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: Add "-f" option to flash firmware image to a
	network device.
Date: Wed, 05 Aug 2009 13:48:23 +0100
Message-ID: <1249476503.2781.3.camel@achroite>
References: <20090805123143.GA6592@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:57211 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933416AbZHEMs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 08:48:29 -0400
In-Reply-To: <20090805123143.GA6592@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-05 at 18:01 +0530, Ajit Khaparde wrote:
> Attached  is a patch for ethtool utility to add a new "-f" option.
> This will enable flashing a firmware image to a network interface.

Which firmware?  There can be several firmware images for controller,
PHY, host boot "ROM" and others.

[...]
> @@ -2398,6 +2404,20 @@ static int do_grxclass(int fd, struct ifreq
> *ifr)
>  	return 0;
>  }
>  
> +static int do_flash(int fd, struct ifreq *ifr)
> +{
> +	int err;
> +	struct ethtool_value ecmd;
> +
> +	ecmd.cmd = ETHTOOL_FLASHDEV;
> +	ifr->ifr_data = (caddr_t)&ecmd;
> +	err = send_ioctl(fd, ifr);
> +	if (err < 0)
> +		perror("Flashing failed");
[..]

Where does the image come from?  The running code?  What about static
variables that have changed since startup?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

