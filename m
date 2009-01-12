From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: re your change to the low_latency flag in the hso driver in
 2.6.29-rc1
Date: Mon, 12 Jan 2009 17:45:31 +0000
Message-ID: <20090112174531.682f49ea@lxorguk.ukuu.org.uk>
References: <496B7CA9.6080403@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Paul Hardwick <P.Hardwick-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <496B7CA9.6080403-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> I remember removing the low_latency flag to 0 once & if I recall correctly performance 
> was severely impacted & there may have been other problems which I don't recall.

The modern buffering and old buffering are rather different so that
shouldn't be a problem.

> Now tty_insert_flip_string can return 0 bytes leading to an infinite loop if tty buffers are full,
> as write_length_remaining never goes to zero as I am dependent on the line
> discipline being called from tty_flip_buffer_push to set TTY_THROTTLED by calling flush_to_ldisc

In all cases tty_insert_flip_string may return 0 for other reasons (eg
out of memory).

> checking if curr_write_len=0 from tty_insert_flip_string might fix the problem
> Please look at put_rxbuf_data carefully, there might be other gremlins. The serial port
> is supposed to be high performance this fix will impact this

Will do, but it should have no impact at all on throughput - in fact it
ought to improve it. You can't call tty_flip_buffer_push() from an
IRQ handler with tty->low_latency set anyway...

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
