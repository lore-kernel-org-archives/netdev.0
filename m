From: Denis Yefremov <yefremov.denis-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: wlcore: might_sleep operation in interrupt handler
Date: Wed, 1 Aug 2012 00:48:17 +0400
Message-ID: <CADKZ3FLs444RfLx=RyBPKs+Lza_mZHhT=zHauMt3BUnqAUtY0w@mail.gmail.com>
References: <CADKZ3FKDw78ac9JPXJuw0s7Mqg1RrVfonbjXZ6zHmtwF2i5HoQ@mail.gmail.com>
	<1343765698.4474.10.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Eliad Peller <eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	Arik Nemtsov <arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>, Eyal Shapira <eyal-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ldv-project-ufN2psIa012HXe+LvDLADg@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1343765698.4474.10.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

More precise (IRQF_ONESHOT flag may be used):

int __devinit wlcore_probe(struct wl1271 *wl, struct platform_device *pdev)
{
...
        if (wl->platform_quirks & WL12XX_PLATFORM_QUIRK_EDGE_IRQ)
                irqflags = IRQF_TRIGGER_RISING;
        else
                irqflags = IRQF_TRIGGER_HIGH | IRQF_ONESHOT;

        ret = request_threaded_irq(wl->irq, wl12xx_hardirq, wlcore_irq,
                                   irqflags,
                                   pdev->name, wl);


2012/8/1 Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>:
> On Tue, 2012-07-31 at 22:28 +0400, Denis Yefremov wrote:
>> Interrupt handler wlcore_irq in wlcore/main.c file
>> invokes mutex_lock that is might sleep operation.
>
>> int __devinit wlcore_probe(struct wl1271 *wl, struct platform_device *pdev)
>> {
>> ...
>>         ret = request_threaded_irq(wl->irq, wl12xx_hardirq, wlcore_irq,
>>                                    irqflags,
>>                                    pdev->name, wl);
>
> Yes, umm, why do you think they're using a *threaded* IRQ? :-)
>
> johannes
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
