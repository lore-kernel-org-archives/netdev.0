From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] at803x: fix reset handling
Date: Wed, 23 Mar 2016 16:30:33 +0300
Message-ID: <56F29A79.5090406@cogentembedded.com>
References: <1525241.UQIRf9ZOB3@wasted.cogentembedded.com>
 <20160323064504.GI6191@pengutronix.de> <56F2847B.5090904@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	Daniel Mack <zonque@gmail.com>
To: Daniel Mack <daniel@zonque.org>,
	=?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:34210 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074AbcCWNaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 09:30:39 -0400
Received: by mail-lf0-f54.google.com with SMTP id c62so8268189lfc.1
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 06:30:38 -0700 (PDT)
In-Reply-To: <56F2847B.5090904@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/23/2016 02:56 PM, Daniel Mack wrote:

>> I added the author of 13a56b449325 to Cc.

> Thanks for doing that!

    I forgot to do it, sorry.

>> On Wed, Mar 23, 2016 at 12:44:40AM +0300, Sergei Shtylyov wrote:
>>> The driver of course "knows" that the chip's reset signal is active low,
>>> so  it drives the GPIO to 0  to reset the PHY and to 1 otherwise; however
>>> all this will only work iff the GPIO  is  specified as active-high in the
>>> device tree!  I think both the driver and the device trees (if there are
>>> any -- I was unable to find them) need to be fixed in this case...
>
> Well, the driver asserts the line by setting it to 1, while in fact the

    Contariwise, it sets GPIO to 0 to assert the reset signal.

> chip itself considers 'low' as 'asserted'.

    My Micrel chips do that as well...

> Hence I opted for flipping the logic in DT rather than in the driver core.

    So did you use GPIO_ACTIVE_LOW or _HIGH in the device tree? AFAIU, only 
the latter ould work with this patch, but it'll be in error.

> IIRC, there was even
> some sort of level-shifting inversion going on in our design, but I
> don't recall the details.
>
> That said, I don't care much. If the general assumption is to make the
> driver calls match the actual output on the peripheral,

    They seem to do now, but that doesn't fly well with the modern gpiolob 
where you can declare the active-low/high for each GPIO, so that gpiolib would 
automatically invert the value for the active-low pins.

> then fine, let's
> turn it around, but that's a matter of interpretation IMO.

>>> Fixes: 13a56b449325 ("net: phy: at803x: Add support for hardware reset")
>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>>
>>> ---
>>> The patch is against DaveM's 'net.git' repo.
>>
>> Don't you need to work against net-next for non-urgent stuff? Or do you
>> consider this urgent?
>
> It's certainly not :)
>
>> The new variant is better than the old one. The change however breaks
>> existing device trees which is not so nice. Given there are no mainline
>> users this is probably ok though. So:
>
> Hmm, one idea for DT was to allow for external board support via DTB
> files, right? Then again, bindings breaks happen all the time anyway.

    Contrariwise, the drivers are supposed to be able to work with older .dtb 
files... but if we have out-of-tree .dtb's to consider only, our hands are 
untied then.

> As far as I'm concerned, I'm fine with the change. If it lands, I'll
> simply give my colleagues a short heads-up so they can flip the bit on
> their side too.

    Thank you. :-)

> Thanks,
> Daniel

MBR, Sergei
