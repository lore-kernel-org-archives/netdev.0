From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH][RFC] Move config NET_NS to from net/Kconfig to
	init/Kconfig
Date: Mon, 26 Jan 2009 11:58:45 -0600
Message-ID: <20090126175845.GA19953@hallyn.com>
References: <1232755651.8282.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Matt Helsley <matthltc@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.124]:54749 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbZAZRzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 12:55:19 -0500
Content-Disposition: inline
In-Reply-To: <1232755651.8282.6.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Matt Helsley (matthltc@us.ibm.com):
> Make NET_NS available underneath the generic Namespaces config option since all of
> the other namespace options are there.
> 
> Signed-off-by: Matt Helsley <matthltc@us.ibm.com>

It would definately be nice to have all the namespace options in
one place.

Acked-by: Serge Hallyn <serue@us.ibm.com>

> ---
>  init/Kconfig |    8 ++++++++
>  net/Kconfig  |    8 --------
>  2 files changed, 8 insertions(+), 8 deletions(-)
> 
> Index: linux-2.6.29-rc1/init/Kconfig
> ===================================================================
> --- linux-2.6.29-rc1.orig/init/Kconfig
> +++ linux-2.6.29-rc1/init/Kconfig
> @@ -541,6 +541,14 @@ config PID_NS
>  	  Unless you want to work with an experimental feature
>  	  say N here.
>  
> +config NET_NS
> +	bool "Network namespace"
> +	default n
> +	depends on NAMESPACES && EXPERIMENTAL && NET
> +	help
> +	  Allow user space to create what appear to be multiple instances
> +	  of the network stack.
> +
>  config BLK_DEV_INITRD
>  	bool "Initial RAM filesystem and RAM disk (initramfs/initrd) support"
>  	depends on BROKEN || !FRV
> Index: linux-2.6.29-rc1/net/Kconfig
> ===================================================================
> --- linux-2.6.29-rc1.orig/net/Kconfig
> +++ linux-2.6.29-rc1/net/Kconfig
> @@ -24,14 +24,6 @@ if NET
>  
>  menu "Networking options"
>  
> -config NET_NS
> -	bool "Network namespace support"
> -	default n
> -	depends on EXPERIMENTAL && NAMESPACES
> -	help
> -	  Allow user space to create what appear to be multiple instances
> -	  of the network stack.
> -
>  config COMPAT_NET_DEV_OPS
>         def_bool y
>  
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
