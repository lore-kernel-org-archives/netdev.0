From: Adrian Bunk <bunk@kernel.org>
Subject: Re: build #337 failed for 2.6.24-rc1-gb1d08ac In function
	`usbnet_set_settings':
Date: Fri, 2 Nov 2007 21:05:41 +0100
Message-ID: <20071102200541.GX30287@stusta.de>
References: <200711012024.57412.toralf.foerster@gmx.de> <200711011632.18333.david-b@pacbell.net> <20071101234443.GD7227@stusta.de> <200711021145.15542.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:50941 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752648AbXKBUGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2007 16:06:05 -0400
Content-Disposition: inline
In-Reply-To: <200711021145.15542.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 02, 2007 at 11:45:15AM -0700, David Brownell wrote:
>...
> --- a.orig/drivers/net/usb/usbnet.c	2007-10-13 15:16:10.000000000 -0700
> +++ a/drivers/net/usb/usbnet.c	2007-11-02 11:39:59.000000000 -0700
> @@ -682,10 +682,17 @@ done_nopm:
>  /* ethtool methods; minidrivers may need to add some more, but
>   * they'll probably want to use this base set.
>   */
> +#undef HAVE_MII
>  
> -#if defined(CONFIG_MII) || defined(CONFIG_MII_MODULE)
> +#if defined(CONFIG_MII)
>  #define HAVE_MII
>  
> +#elif defined(CONFIG_MII_MODULE) && defined(MODULE)
> +#define HAVE_MII
> +#endif
> +
> +#ifdef HAVE_MII
> +
>  int usbnet_get_settings (struct net_device *net, struct ethtool_cmd *cmd)
>  {
>  	struct usbnet *dev = netdev_priv(net);
> 

Despite all what you do in Kconfig and what you wrongly blame on 
"select" the bug is in usbnet.c and this fix to usbnet.c _alone_  
would be enough to fix the bug.

But since you said you care about not including bloat you should better 
take my second patch that results in smaller code in some configurations.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

