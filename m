From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [PATCH]  hso.c against 2.6.27-rc5 throttle/unthrottle to
 prevent loss of serial data
Date: Fri, 5 Sep 2008 14:59:02 +0100
Message-ID: <20080905145902.1f84e729@lxorguk.ukuu.org.uk>
References: <48C0FD6A.10706@option.com>
	<20080905140919.05f9edd8@lxorguk.ukuu.org.uk>
	<48C13458.50803@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48C13458.50803-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

O> If my understanding of the n_tty.c code is correct it will
> only start throttling when there is TTY_THRESHOLD_THROTTLE
> i.e. 128 bytes left in the n_tty ring buffer this is a very low limit
> for my driver. This means
> that if I try to do a tty_flip_buffer_push of
> of a tty buffer larger than 128 bytes when the threshold
> is reached I will lose data. My urb buffers are 4k in
> size 2 buffers of this size up to the tty layer in a row 
> quickly I believe I'll lose data in the n_tty layer.

If there is 128 bytes left in the n_tty buffer and you push data it ends
up in the tty_buffer queue where it will accumulate up to 64K of data
which will be fired into the tty layer when the tty layer is willing to
accept it (sets its receive_room).

Alan
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
