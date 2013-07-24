From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/3] tuntap: allow overriding ethtool driver
 info
Date: Thu, 25 Jul 2013 00:48:07 +0100
Message-ID: <1374709687.1732.46.camel@bwh-desktop.uk.level5networks.com>
References: <20130724161156.4a8cf02b@nehalam.linuxnetplumber.net>
	 <20130724161325.38404ed3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Helmut Grohne <h.grohne@cygnusnetworks.de>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20496 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753209Ab3GXXsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 19:48:11 -0400
In-Reply-To: <20130724161325.38404ed3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-24 at 16:13 -0700, Stephen Hemminger wrote:
> This patch adds new ioctl to allow setting the ethtool information
> returned by the TUN device. This is useful when using tun device as a surrogate
> for hardware or other software emulation.

I don't like this idea.  Which tools are you trying to fool?  How does
this work when you don't implement any driver-specific behaviour (e.g.
SIOCDEVPRIVATE) they expect?

> If the application does not override the ethtool settings, the
> original hard coded values are used.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
[...]
> --- a/include/uapi/linux/if_tun.h	2013-07-24 11:24:55.543040360 -0700
> +++ b/include/uapi/linux/if_tun.h	2013-07-24 11:35:54.620898504 -0700
> @@ -56,6 +56,7 @@
>  #define TUNGETVNETHDRSZ _IOR('T', 215, int)
>  #define TUNSETVNETHDRSZ _IOW('T', 216, int)
>  #define TUNSETQUEUE  _IOW('T', 217, int)
> +#define TUNSETINFO     _IOW('T', 219, struct tun_info)
>  
>  /* TUNSETIFF ifr flags */
>  #define IFF_TUN		0x0001
> @@ -103,4 +104,11 @@ struct tun_filter {
>  	__u8   addr[0][ETH_ALEN];
>  };
>  
> +/* Subset of ethtool_info */
> +struct tun_info {
> +	char driver[32];
> +	char bus[32];
> +	char version[32];
> +};
> +
>  #endif /* _UAPI__IF_TUN_H */

What about fw_version?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
