From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] Allow change timing values to wait slow devices
 bring up  before try register an interface to IP-Config
Date: Tue, 9 Feb 2010 21:51:20 -0800
Message-ID: <20100209215120.ac46ff7c.akpm@linux-foundation.org>
References: <600adaf51002091947ta095cc5g7174684f57488e94@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Tiago Maluta <tiago.maluta@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <600adaf51002091947ta095cc5g7174684f57488e94@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 10 Feb 2010 03:47:59 +0000 Tiago Maluta <tiago.maluta@gmail.com> wrote:
>
> 

Please cc netdev@vger.kernel.org on net patches - linux-net@vger is not
used for development.

> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index dd9a09c..12fbe4a 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -38,6 +38,24 @@ config IFB
>  	  'ifb1' etc.
>  	  Look at the iproute2 documentation directory for usage etc
> 
> +config NETDEVICES_DELAY_PRE_OPEN
> +	int "Define the delay before opening net devices (ms)"
> +	depends on NETDEVICES
> +	default 500
> +	help
> +	    Some devices may not work properly due to a delay from hardware bring
> +	    the interface up. This value add a delay, in miilliseconds, before

typo.

> +	    kernel search and register the interface. Default value is 500ms.
> +
> +config NETDEVICES_DELAY_POST_OPEN
> +	int "Define the delay after opening net devices (s)"
> +	depends on NETDEVICES
> +	default 1
> +	help
> +	    Some devices may not work properly due to a delay from hardware bring
> +	    the interface up. This value add a delay, in seconds, after
> +	    kernel search and register the interface. Default value is 1s.
> +
>  config DUMMY
>  	tristate "Dummy net driver support"
>  	---help---
> diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
> index 10a6a60..2530126 100644
> --- a/net/ipv4/ipconfig.c
> +++ b/net/ipv4/ipconfig.c
> @@ -86,8 +86,8 @@
>  #endif
> 
>  /* Define the friendly delay before and after opening net devices */
> -#define CONF_PRE_OPEN		500	/* Before opening: 1/2 second */
> -#define CONF_POST_OPEN		1	/* After opening: 1 second */
> +#define CONF_PRE_OPEN		CONFIG_NETDEVICES_DELAY_PRE_OPEN	/* Before
> opening. Default is 1/2 second */
> +#define CONF_POST_OPEN		CONFIG_NETDEVICES_DELAY_POST_OPEN	/* After
> opening. Default is 1 second */

Your email client wordwrapped this.

Using delays was dumb of us, but I guess the problem is difficult.

It would be much better to configure this delay at runtime rather than
at compile time.  Perhaps with new kernel boot parameters, perhaps by
extending the ip= argument.
