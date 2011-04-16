From: =?UTF-8?B?RmVqZXMgSsOzenNlZg==?= <fejes@joco.name>
Subject: Re: r8169 misleading firmware error messages
Date: Sat, 16 Apr 2011 14:06:38 +0200
Message-ID: <4DA9864E.2070405@joco.name>
References: <4DA952D5.7030805@joco.name> <20110416110454.GC17833@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?RnJhbsOnb2lzIFJvbWlldQ==?= <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01d.mail.t-online.hu ([84.2.42.6]:13087 "EHLO
	mail01d.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051Ab1DPMN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2011 08:13:28 -0400
In-Reply-To: <20110416110454.GC17833@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I see there's a condition, if an rtl_readphy returns a wrong value, it
>> doesn't even try to load the firmware and just prints the message.
>> Although this wouldn't explain why the error message disappeared
>> when the files were there.
>
> I don't get your point.

I meant this:

2233         if ((rtl_readphy(tp, 0x06) != 0xbf00) ||
2234             (rtl_apply_firmware(tp, FIRMWARE_8168D_1) < 0)) {
2235                 netif_warn(tp, probe, tp->dev, "unable to apply 
firmware patch\n");
2236         }

So if a user sees this warning, they don't know if the right firmware is 
missing or something else is wrong with the device and it doesn't even 
try to load the firmware.

>
>> Clearly, my device works without these firmware files. If my device
>> works better with them, or if there are other similar devices which
>> require it, I think there should be a configuration option to
>> disable this firmware stuff and its benefits altogether so that it
>> doesn't even report that it needs it.
>
> The driver uses netif_warn, not netif_err.
>
> I think the driver is nevrotic enough as is and I will not add
> what I consider a silly if not unusable configuration option.
>
> Feel free to send patches if you think they really add some
> value.
>

I took a deeper look. It seems to me that the firmware files are not the 
usual microcode type that the device can't function without, it just 
sets up some registers, which supposedly already contain some sensible 
values, so it's more like patching. That explains why this device still 
works without the firmware. So my actual question is this: what do I 
gain if I use the firmware, what do I lose if I don't? Since the 
previous kernel version, either something pretty important was moved out 
of the code into the firmware file, in which case it's a bad idea not to 
use them, or they add some features to an already perfectly working 
device, in which case I thought it could be a good idea to make it a 
configuration option. I'd just like to understand because I couldn't 
find any documentation, I don't mean to question your decisions.
