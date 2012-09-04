From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH net] net: usbnet: fix softirq storm on suspend
Date: Tue, 4 Sep 2012 17:38:36 +0800
Message-ID: <CACVXFVMEqF9+e10oRuTHjkKQOnPnJMXxapXZ9rYG9qWRpZPLKw@mail.gmail.com>
References: <1346660778-24539-1-git-send-email-bjorn@mork.no>
	<CACVXFVNykwxe-PYP_nin32htFmrFL4d=3DEhZMo3UwTEpb81+A@mail.gmail.com>
	<87y5kqcjnp.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87y5kqcjnp.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 4, 2012 at 3:49 PM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
>
> That's easy:
>
> - Take any usbnet device supporting remote wakeup (and of course with=
 a
>   minidriver supporting it as well),
> - enable autosuspend,
> - ip link set dev ethX/usbX/wwanX up
>
> And watch ksoftirqd/X use 100% of one of your CPU cores.
>
> I'd very much like to hear the details if you are unable to reproduce
> the bug using this simple test.

I have no such kind of devices, and can't reproduce the problem with
a cdc-ether gadget built by one omap3 beagleboard.

>> Once usbnet_terminate_urbs and netif_device_attach() are
>> completed, who will schedule tasklet to trigger rx_alloc_submit?
>
> That's a good question.  It sure would be nice if that never happened
> without waking the device first.  But there are just too many call si=
tes
> for me to follow:

To be honest, your patch is correct, and I am just curious about
the reason why tasklet is scheduled after the device is suspended.

>
> bjorn@nemi:/usr/local/src/git/linux$ grep tasklet_schedule drivers/ne=
t/usb/usbnet.c
>                 tasklet_schedule(&dev->bh);
>  * but tasklet_schedule() doesn't.  hope the failure is rare.
>                         tasklet_schedule (&dev->bh);
>         tasklet_schedule(&dev->bh);
>                 tasklet_schedule(&dev->bh);
>         tasklet_schedule (&dev->bh);
>                         tasklet_schedule (&dev->bh);
>                                 tasklet_schedule (&dev->bh);
>         tasklet_schedule (&dev->bh);
>                                 tasklet_schedule (&dev->bh);
>                         tasklet_schedule (&dev->bh);

Could you add some debug info inside the caller to see which one
cause the tasklet to be scheduled?


Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
