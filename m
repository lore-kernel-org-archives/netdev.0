From: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Subject: Re: use of preempt_count instead of in_atomic() at leds-gpio.c
Date: Fri, 21 Mar 2008 10:27:34 +0100
Message-ID: <47E37F86.2080804@s5r6.in-berlin.de>
References: <20080316184349.GA28543@khazad-dum.debian.net>	<200803161246.23909.david-b@pacbell.net>	<20080318001429.896acf51.akpm@linux-foundation.org>	<20080320225612.GB20788@khazad-dum.debian.net>	<20080320164741.734e838c.akpm@linux-foundation.org>	<20080321003604.GC20788@khazad-dum.debian.net> <20080320180802.426ad2d1.akpm@linux-foundation.org> <47E37E04.3080303@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>,
	David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>,
	Richard Purdie <rpurdie-Fm38FmjxZ/leoWH0uzbU5w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	video4linux-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, lm-sensors-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <47E37E04.3080303-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I wrote:
> Andrew Morton wrote:
>> ./drivers/ieee1394/ieee1394_transactions.c
>>
>>   Possibly buggy: deadlockable
> 
> That's in hpsb_get_tlabel(), an exported symbol of the ieee1394 core.
> 
> The in_atomic() there didn't cause problems yet and is unlikely to do so 
> in the future, because there are no plans for substantial changes to the 
> whole drivers/ieee1394/ anymore (because of drivers/firewire/).
> 
> Nevertheless I shall look into replacing the in_atomic() by in_softirq() 
> or something like that.

Or extend the API to have separate calls for callers which can sleep and 
callers which can't.  But that may be thwarted by deep call chains.

> Touching this legacy code is dangerous though.
-- 
Stefan Richter
-=====-==--- --== =-=-=
http://arcgraph.de/sr/
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
