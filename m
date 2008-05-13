From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [PATCH] HSO: add option hso driver
Date: Tue, 13 May 2008 23:27:27 +0100
Message-ID: <20080513232727.21c74bb2@core>
References: <20080513215134.GC6139@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Bird <ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org>,
	Javier Marcet <javier-cnb5s7aUzWrdtAWm4Da02A@public.gmane.org>,
	Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080513215134.GC6139-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Jeff, please queue this up for 2.6.27 if there are no problems that you
> can see.  It has been in the linux-next tree for a while, and many users
> are reporting that it is working for them.
> 
> Or if you feel it's ok for 2.6.26, I will not object to that either :)

Can we get it into 2.6.26 - its a driver for new hardware and the driver
is going to get a clean up for 2.6.27 anyway.

Comments below are minor and I don't think blockers

So for the serial side

Acked-by: Alan Cox <alan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>


> +	termios = serial->tty->termios;

tty is passed why keep using serial->tty (hint: think about parallel
hangup versus close/open)

> +/* close the requested serial port */
> +static void hso_serial_close(struct tty_struct *tty, struct file *filp)
> +{
> +	struct hso_serial *serial = tty->driver_data;
> +	u8 usb_gone;
> +
> +	D1("Closing serial port");
> +
> +	/* sanity check */
> +	if (tty == NULL || serial == NULL) {
> +		D1("(tty == NULL || tty->driver_data == NULL)");
> +		return;
> +	}

tty cannot be NULL here


> +static int hso_serial_write(struct tty_struct *tty, const unsigned char *buf,
> +			    int count)
> +{
> +	struct hso_serial *serial = get_serial_by_tty(tty);
> +	int space, tx_bytes;
> +	unsigned long flags;
> +
> +	/* sanity check */
> +	if (serial == NULL) {
> +		printk(KERN_ERR "%s: tty or tty->driver_data is NULL\n",

Checks one thing printks another 8)

> +	/* the actual setup */
> +	spin_lock_irqsave(&serial->serial_lock, flags);
> +	if (serial->open_count)
> +		_hso_serial_set_termios(tty, old);

(else *tty->termios = *old_termios)


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
