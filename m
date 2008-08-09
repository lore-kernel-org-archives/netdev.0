From: Paul Rolland <rol@as2917.net>
Subject: Re: [02/04] hso: fix refcounting on the ttyHSx devices
Date: Sat, 9 Aug 2008 10:39:57 +0200
Message-ID: <20080809103957.5580bf6c@tux.DEF.witbe.net>
References: <20080808190023.GA2953@kroah.com>
	<20080808190141.GC2953@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Jari Tenhunen <jari.tenhunen@iki.fi>,
	Olivier Blin <blino@mandriva.com>,
	Andrew Bird <ajb@spheresystems.co.uk>,
	Arjan van de Ven <arjan@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>, rol@witbe.net
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.witbe.net ([81.88.96.48]:39452 "EHLO smtp.witbe.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752242AbYHIIsl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Aug 2008 04:48:41 -0400
In-Reply-To: <20080808190141.GC2953@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This single patch fixes the problem of the left-over /dev/ttyHSx when
unplugging the Icon device from the USB port. Everything else I'm using is
still working correctly as far as I can see, so you can add a :

Tested-By: Paul Rolland <rol@as2917.net>

Thanks for that,
Regards,
Paul

On Fri, 8 Aug 2008 12:01:41 -0700
Greg KH <greg@kroah.com> wrote:

> From: Olivier Blin <blino@mandriva.com>
> 
> 
> The references on ttyHSx devices were not decremented correctly when
> the tty was closed. The helper freeing the serial devices was never
> called because of that, and the module left some dangling sysfs
> devices after being unloaded.
> 
> Signed-off-by: Olivier Blin <blino@mandriva.com>
> Cc: Jari Tenhunen <jari.tenhunen@iki.fi>
> Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> 
> ---
>  drivers/net/usb/hso.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -1103,8 +1103,8 @@ static void hso_serial_close(struct tty_
>  	/* reset the rts and dtr */
>  	/* do the actual close */
>  	serial->open_count--;
> +	kref_put(&serial->parent->ref, hso_serial_ref_free);
>  	if (serial->open_count <= 0) {
> -		kref_put(&serial->parent->ref, hso_serial_ref_free);
>  		serial->open_count = 0;
>  		if (serial->tty) {
>  			serial->tty->driver_data = NULL;
> 


-- 
Paul Rolland                                E-Mail : rol(at)witbe.net
CTO - Witbe.net SA                          Tel. +33 (0)1 47 67 77 77
Les Collines de l'Arche                     Fax. +33 (0)1 47 67 77 99
F-92057 Paris La Defense                    RIPE : PR12-RIPE

Please no HTML, I'm not a browser - Pas d'HTML, je ne suis pas un navigateur 
"Some people dream of success... while others wake up and work hard at it" 

"I worry about my child and the Internet all the time, even though she's too 
young to have logged on yet. Here's what I worry about. I worry that 10 or 15 
years from now, she will come to me and say 'Daddy, where were you when they 
took freedom of the press away from the Internet?'"
--Mike Godwin, Electronic Frontier Foundation 
