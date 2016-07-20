From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH 2/3] staging/rtl8192e: use s8 instead of char
Date: Wed, 20 Jul 2016 09:25:59 -0500
Message-ID: <29c970ef-0bd5-38f2-48fd-91adb01fc8a9@lwfinger.net>
References: <20160719153403.2967812-1-arnd@arndb.de>
 <3858062.NGQDOLnTj0@wuerfel> <wrfjlh0xvck3.fsf@redhat.com>
 <4806848.QL77nxBrs4@wuerfel> <wrfjlh0wsg9s.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Mateusz Kulikowski <mateusz.kulikowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrea Merello <andrea.merello-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Jes Sorensen <Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <wrfjlh0wsg9s.fsf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/20/2016 06:25 AM, Jes Sorensen wrote:
> Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> writes:
>> On Tuesday, July 19, 2016 12:05:00 PM CEST Jes Sorensen wrote:
>>> Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> writes:
>>> I think that would be better, albeit not a big issue.
>>
>> Ok, and since Kalle applied the first patch to his tree, I'm now sending
>> a series of three patches that are all for Greg, which also avoids some
>> possible confusion.
>
> Awesome!
>
>>> I'd like to get rid of all the drivers/staging/rtl* drivers eventually
>>
>> That would be great, yes.
>>
>> Can you clarify what the long-term plan is? I see that
>> drivers/net/wireless/realtek/rtlwifi/ has most of the PCIe parts
>> and one USB device (rtl8192cu/rtl8188cus) while
>> drivers/net/wireless/rtl8xxx has all the USB parts including
>> that one.
>>
>> Does that mean we want the staging drivers for PCIe devices
>> to get merged into rtlwifi, and the remaining USB drivers to get
>> replaced by r8xxxu?
>
> Well it really all depends on how much time I have and how much others
> step up and help contribute to the code. For rtl8xxxu my plans are as
> follows:
>
> 1) rtl8188eu support, since this is the most widely distributed USB
> dongle which isn't currently supported by a non staging driver. I am
> currently working on this together with Andrea Merello.
>
> 2) Beacon support for IBSS and AP mode - hopefully this should make it
> possible to default rtl8xxxu for rtl8192cu/rtl8188cu devices and disable
> them in rtlwifi.
>
> 3) SDIO device support
>
> 4) PCI device support
>
> 5) 802.11ac device support
>
> 3/4/5 not necessarily in that order. There really is no reason why
> rtl8xxxu shouldn't have SDIO and PCI device support added so the core
> code can be shared.
>
>> As one data point that I can provide (but you are probably
>> aware of), I could never get my rtl8188cus stick to work with
>> rtlwifi, but I found the older r8712u device to work fine with
>> the staging/rtl8712 driver.
>
> I'd love to hear if the rtl8188cus works better with rtl8xxxu. For the
> rtl8712 device, rtl8192su?, then potentially that could be added to
> rtl8xxxu as well, but it's not a top priority on my list right now.

I would be very pleased to eliminate all the rtl* drivers from staging, 
particularly the USB varieties. I have been very disappointed with the USB group 
at Realtek. They dropped rtl8192cu on me, and then have provided no support. As 
I know nothing of the chip internals, there has been little I could do to 
improve the driver. In addition, they have never implemented any of the code 
improvements in any new USB drivers. Jes has done a wonderful job of making 
sense of the crap drivers from Realtek, and rtl8xxxu is a very good start. 
Adding SDIO support for the RTL8723BS would be a plus. At the moment, there is 
only an out-of-tree driver at GitHub, which I refuse to submit to staging. At 
the moment, it appears that every tablet with this chip needs special treatment. 
In addition, the SDIO support seems to be buggy.

The drivers in question and my comments are as follows:

rtl8712u and rtl8188eu - replaced by new code in rtl8xxxu.
rtl8723au - already in rtl8xxxu
rtl8192e - This chip is so rarely used that it does not make much difference 
what we do. If someone wants to integrate it into rtlwifi, I would have no 
objection, but I do not expect to contribute to the effort.
rtl8192u - This one is even rarer. I have no sample, thus I would be unable to test.
rtl8192cu - Replace with rtl8xxxu as soon as the new driver supports beacons. 
Good riddance.

Larry

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
