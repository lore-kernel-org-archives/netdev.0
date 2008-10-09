From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: Re: small design problem with hso driver
Date: Thu, 09 Oct 2008 11:01:59 +0200
Message-ID: <48EDC887.8010403@option.com>
References: <48ECBB26.7080402@option.com> <20081008174556.GA15387@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081008174556.GA15387-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,
I've found something suspicous but am not sure if
it's my problem. It looks like it when I'm
doing a gdb debug session but I can't believe
code so wrong can get into the kernel
& it didn't cause problems before.

Have a look at /drivers/char/tty_io.c

tty_open

around line 2234 this calls
tty->ops->open which calls hso_serial_open
& if this returns an error i.e. -ENODEV
release_dev is called which calls in tty_open
which calls tty->ops_close around line 2003 in tty_io.c.

Surely if the driver returns an error code on hso_serial_open
hso_serial_close shouldn't be called
or have I a complete misunderstanding
of char driver semantics.

Greg KH wrote:
> On Wed, Oct 08, 2008 at 03:52:38PM +0200, Denis Joseph Barrow wrote:
>> Hi,
>> I'm getting a fairly consistently reproducable problem
>> with the 3g modem hso driver. The most reproducable
>> bug I have.
>>
>> It happens when I plug out the usb modem & ctrl-c
>> out of an ioctl call with the modem connected in paralell over ppp
>> with wvdial 
>>
>> Basically whats happening is the hso_serial_close
>> is being called more times than the hso_serial_open &
>> I don't know why.
> 
> Care to put a trace or printk() to determine who is doing each open and
> close?
> 
> thanks,
> 
> greg k-h


-- 
best regards,
D.J. Barrow
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
