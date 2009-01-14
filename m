From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/02] hso patch to fix a -EIO from opening a hso serial
 device
Date: Wed, 14 Jan 2009 13:40:34 +0100
Message-ID: <496DDD42.6060601@option.com>
References: <496DCAF7.9080906@option.com> <20090114113828.7b9f59ca@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Serial <linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090114113828.7b9f59ca-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alan,
Your fix works too I suspect better than mine & since you've a better idea of what
you are doing with tty layer than I do we'll stick with
your fix.

Do you want me to switch off the low latency stuff in the
driver?

I also need to investigate the tty_kref_put & tty_kref_get
& when it was added to the kernel so I can fix stuff for our
internal driver



Alan Cox wrote:
> On Wed, 14 Jan 2009 12:22:31 +0100
> Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org> wrote:
> 
>> Hi All,
>> This is an important patch the linux-2.6.29-rc1 driver with itworks much
>> better than it did.
> 
> How about this. 
> 
> tty: Fix a kref leak in the HSO driver on re-open
> 
> From: Alan Cox <alan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> 
> 
> ---
> 
>  drivers/net/usb/hso.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> 
> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index c4918b8..9df04dd 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -1297,6 +1297,7 @@ static int hso_serial_open(struct tty_struct *tty, struct file *filp)
>  	/* setup */
>  	spin_lock_irq(&serial->serial_lock);
>  	tty->driver_data = serial;
> +	tty_kref_put(serial->tty);
>  	serial->tty = tty_kref_get(tty);
>  	spin_unlock_irq(&serial->serial_lock);
>  


-- 
best regards,
D.J. Barrow

Linux Kernel Developer
Option NV, Gaston Geenslaan 14, 3001 Leuven, Belgium
 
T: +32 16 311 621
F: +32 16 207 164
d.barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
www.option.com

Disclaimer:
http://www.option.com/company/disclaimer.shtml
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
