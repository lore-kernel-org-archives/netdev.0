From: Andy Green <andy-/Zus8d0mwwtBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Thu, 24 Mar 2011 10:45:34 +0000
Message-ID: <4D8B20CE.5030101@linaro.org>
References: <4D79F068.2080009@linaro.org> <201103231756.39849.arnd@arndb.de> <4D8A2830.6020706@linaro.org> <201103231811.54290.arnd@arndb.de>
Reply-To: andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Nicolas Pitre <nicolas.pitre-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Jaswinder Singh <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Linux USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org, roger.quadros-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org,
	grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201103231811.54290.arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/23/2011 05:11 PM, Somebody in the thread at some point said:
> On Wednesday 23 March 2011, Andy Green wrote:
>>> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
>>> index bc86f4b..c98d3a7 100644
>>> --- a/drivers/net/usb/smsc95xx.c
>>> +++ b/drivers/net/usb/smsc95xx.c
>>> @@ -1231,7 +1231,7 @@ static const struct driver_info smsc95xx_info = {
>>
>>> -     .flags          = FLAG_ETHER | FLAG_SEND_ZLP,
>>> +     .flags          = FLAG_ETHER | FLAG_SEND_ZLP | FLAG_REALLY_ETHER,
>>
>>>                if ((dev->driver_info->flags&   FLAG_ETHER) != 0&&
>>> +                 ((dev->driver_info->flags&   FLAG_PTP) == 0 ||
>>> +                  (net->dev_addr [0]&   0x02) == 0))
>>>                        strcpy (net->name, "eth%d");
>>
>> So it just takes the approach that all smsc95xx are going to be eth%d?
>
> Right, and all other drivers that are obviously ethernet-only, including
> future drivers.

I moved my tree over to using this patch now, it's working fine on Panda 
/ smsc95xx as one would expect.  Guys with pluggable smsc95xx are going 
to find their device comes as eth%d not usb%d but that seems perfectly 
defensible as how it always should have been.

So, nice job.

-Andy
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
