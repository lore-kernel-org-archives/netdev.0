From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH v2] drivers: net: Fix dependency for EEPROM_93CX6
Date: Thu, 05 Jan 2012 14:16:39 -0600
Message-ID: <4F060527.5080801@lwfinger.net>
References: <1325770673-17309-1-git-send-email-festevam@gmail.com>  <4F05CBA9.1070602@lwfinger.net>  <20120105.122004.1170447281304011158.davem@davemloft.net>  <CAOMZO5AuZ_MHW3C1uNK7PyRz=XRHXhn2pvKCwk7iXLDd0YkDOQ@mail.gmail.com>  <CAOMZO5DTDpp8+9FOjPXGFQtQPg7Pv5qfAwFO3UC6AUdEDgpHYg@mail.gmail.com> <1325791078.3764.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Fabio Estevam <festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, fabio.estevam-KZfg59tc24xl57MIdRCFDg@public.gmane.org
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1325791078.3764.30.camel@bwh-desktop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/05/2012 01:17 PM, Ben Hutchings wrote:
> On Thu, 2012-01-05 at 17:02 -0200, Fabio Estevam wrote:
>> On Thu, Jan 5, 2012 at 4:06 PM, Fabio Estevam<festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>  wrote:
>>
>>> I have tried selecting MISC_DEVICES in the Kconfig's, but the warning remains.
>>>
>>> I agree with Ben's comment: "That seems like a bug, since MISC_DEVICES
>>> doesn't by itself select any
>>> code.  (It's also not a meaningful category and maybe ought not to be an
>>> option at all.)"
>>
>> What about the aproach below?
>>
>> drivers/misc/Kconfig |   12 ++----------
>>   1 files changed, 2 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
>> index 6a1a092..9c7a474 100644
>> --- a/drivers/misc/Kconfig
>> +++ b/drivers/misc/Kconfig
>> @@ -10,15 +10,8 @@ config SENSORS_LIS3LV02D
>>   	select INPUT_POLLDEV
>>   	default n
>>
>> -menuconfig MISC_DEVICES
>> -	bool "Misc devices"
>> -	---help---
>> -	  Say Y here to get to see options for device drivers from various
>> -	  different categories. This option alone does not add any kernel code.
>> -
>> -	  If you say N, all options in this submenu will be skipped and disabled.
>> +menu "Misc devices"
>>
>> -if MISC_DEVICES
>>
>>   config AD525X_DPOT
>>   	tristate "Analog Devices Digital Potentiometers"
>> @@ -516,5 +509,4 @@ source "drivers/misc/ti-st/Kconfig"
>>   source "drivers/misc/lis3lv02d/Kconfig"
>>   source "drivers/misc/carma/Kconfig"
>>   source "drivers/misc/altera-stapl/Kconfig"
>> -
>> -endif # MISC_DEVICES
>> +endmenu
>
> Yes, that's what I was thinking of.
>
>> This would remove the unneeded dependency of MISC_DEVICES.
>>
>> I know I need to take extra care not to break other things, but just
>> would like to get a feedback if this approach goes into the right
>> direction.
>
> Right, you'll have to delete all dependencies on MISC_DEVICES.  Maybe
> remove it from defconfigs as well, though I'm not sure whether it's
> normal to do that at the same time.

I also think this is the correct approach.

In the drivers/ tree, there are two mentions of MISC_DEVICES left:

finger@larrylap:~/wireless-testing-new> grep -r MISC_DEVICES drivers/*
drivers/misc/Kconfig:# This one has to live outside of the MISC_DEVICES conditional,
drivers/mmc/host/Kconfig:       select MISC_DEVICES

Larry

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
