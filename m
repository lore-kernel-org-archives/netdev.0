From: "Alexey Klimov" <klimov.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch v2] net/usb: remove err() messages in few drivers
Date: Wed, 14 Jan 2009 03:22:26 +0300
Message-ID: <208cbae30901131622heccfee6uf312022ba1d4fb28@mail.gmail.com>
References: <1231805322.12962.4.camel@tux.localhost>
	 <200901130144.26162.david-b@pacbell.net>
	 <208cbae30901130208xe47d222g6928cf4243ea1dd8@mail.gmail.com>
	 <200901131207.03724.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Brownell" <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	"Greg KH" <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Oliver Neukum" <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200901131207.03724.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello, all

On Tue, Jan 13, 2009 at 2:07 PM, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> wrote:
> Am Tuesday 13 January 2009 11:08:27 schrieb Alexey Klimov:
>> On Tue, Jan 13, 2009 at 12:44 PM, David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org> wrote:
>> > On Tuesday 13 January 2009, Oliver Neukum wrote:
>> >> > Ok, i'll reformat patch. Is it okay if i use kaweth->dev->dev,
>> >> > kaweth->net->dev and intf->dev ? Or switch to kaweth->net->dev
>> >> > (instead of dev->dev)?
>> >>
>> >> kaweth in kaweth_disconnect() frees the network device. Therefore
>> >> you cannot use it. You'd access freed memory. Pick one of the others
>> >> and stay with it.
>> >
>> > intf->dev is going to be "obviously correct", the others aren't.
>> >
>>
>> Is this patch touch  kaweth_disconnect() ? I see dev_warn and dev_info
>> there. No dev_err.
>
> No, it does not. But you need to make sure that the devices you refer to
> in debug messages are always valid. Functions that you do touch may
> run after disconnect() has run. A debug message that oopses does no good.
> If you cannot make sure you pass a valid device to dev_err/info don't use
> them. It is as simple as that.

Yes, that's obviously right. I'll review and check patch again.
Thank you for your advices.


On Tue, Jan 13, 2009 at 12:46 PM, David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org> wrote:
> On Monday 12 January 2009, Alexey Klimov wrote:
>> -                               err("submit(rx_urb) status %d", res);
>> +                               dev_err(&catc->usbdev->dev, "submit(rx_urb) status %d\n", res);
>
>
> That's the same as urb->dev though.
>
> Use the interface passed into probe():  dev_err(&intf->dev, ...) etc

Well, in few v4l-dvb drivers successfully used &radio->usbdev->dev in
debug messages and that doesn't look wrong.

Hmm, i see that struct usb_interface passed to probe function for
example, and here in catc_irq_done struct urb passed, and then we have
struct catc. So, messages based on catc->usbdev->dev. I can switch to
&catc->netdev->dev when it's safe to do, right?
I didn't see way we can use &intv->dev in such functions. Am i wrong ?
In probe functions &intf->dev is right.

Btw, in patch "USB: remove info() macro from usb network drivers"

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=880c9c66a60c0aa4fb4dac2da9679da5f8f41903

few messages based on &urb->dev->dev.

-- 
Best regards, Klimov Alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
