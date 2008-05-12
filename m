From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [PATCH -next] net: hso driver uses rfkill functions
Date: Mon, 12 May 2008 11:29:20 +0300
Message-ID: <4827FFE0.1050702@teltonika.lt>
References: <20080509095140.520aa39c.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, ajb@spheresystems.co.uk,
	jgarzik <jgarzik@pobox.com>, akpm <akpm@linux-foundation.org>,
	Greg KH <greg@kroah.com>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-135-208-232.static.zebra.lt ([82.135.208.232]:53403 "EHLO
	[82.135.208.232]" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751221AbYELIkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 04:40:03 -0400
In-Reply-To: <20080509095140.520aa39c.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

AFAIK Greg has (or he is going to do it) patch for rfkill so no more 
depends or select RFKILL will be needed.

BR,
Paulius Zaleckas

Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> hso driver uses rfkill functions so should either depend on RFKILL
> or select it.  This patch uses depends on RFKILL.
> 
> drivers/built-in.o: In function `hso_disconnect':
> hso.c:(.text+0x868c9): undefined reference to `rfkill_unregister'
> drivers/built-in.o: In function `hso_probe':
> hso.c:(.text+0x88226): undefined reference to `rfkill_allocate'
> hso.c:(.text+0x8829e): undefined reference to `rfkill_register'
> hso.c:(.text+0x8860f): undefined reference to `rfkill_free'
> make[1]: *** [.tmp_vmlinux1] Error 1
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  drivers/net/usb/Kconfig |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- next-20080509.orig/drivers/net/usb/Kconfig
> +++ next-20080509/drivers/net/usb/Kconfig
> @@ -156,7 +156,7 @@ config USB_NET_AX8817X
>  
>  config USB_HSO
>  	tristate "Option USB High Speed Mobile Devices"
> -	depends on USB
> +	depends on USB && RFKILL
>  	default n
>  	help
>  	  Choose this option if you have an Option HSDPA/HSUPA card.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
