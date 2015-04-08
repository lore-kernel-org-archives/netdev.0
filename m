From: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 01/14] parport: return value of attach and
 parport_register_driver
Date: Wed, 8 Apr 2015 17:20:10 +0530
Message-ID: <20150408115010.GA11153@sudip-PC>
References: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
 <1428492040-5581-2-git-send-email-sudipm.mukherjee@gmail.com>
 <20150408113832.GH10964@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Jean Delvare <jdelvare-l3A5Bk7waGM@public.gmane.org>,
	Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>,
	Rodolfo Giometti <giometti-AVVDYK/kqiJWk0Htik3J/w@public.gmane.org>,
	"James E.J. Bottomley" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Willy Tarreau <willy-859RlTSWH48dnm+yROfE0A@public.gmane.org>,
	Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>, Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>,
	devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150408113832.GH10964@mwanda>
Sender: linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 08, 2015 at 02:38:32PM +0300, Dan Carpenter wrote:
> 1) We can't apply this patch on its own so this way of breaking up the
> patches doesn't work.
yes, if the first patch is reverted for any reason all the others need
to be reverted also. so then everything in one single patch?
> 
> 2) I was thinking that all the ->attach() calls would have to succeed or
> we would bail.  Having some of them succeed and some fail doesn't seem
> like it will simplify the driver code very much.  But I can also see
> your point.  Hm...
to clarify my point more here: any system might have more than one
parallel port but the module might decide to use just one. so in that
case attach will return 0 for the port that it wishes to use, for others
it will be a error code. So in parport_register_driver if we get error
codes in all the attach calls then we know that attach has definitely
failed, but atleast one 0 means one attach call has succeeded, which
will happen in case of staging/panel, net/plip...

> 
> Minor comment:  No need to preserve the error code if there are lots
> which we miss.  We may as well hard code an error code.  But that's a
> minor thing.  Does this actually simplify the driver code?  That's the
> more important thing.

i don't think this will simplify the driver code, but atleast now
parport_register_driver() will not report success when we have actually
failed. And as a result module_init will also fail which is supposed to
be the actual behviour.

regards
sudip

> 
> regards,
> dan carpenter
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-spi" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
