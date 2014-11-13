From: Enric Balletbo Serra <eballetbo@gmail.com>
Subject: Re: [PATCH] smsc911x: power-up phydev before doing a software reset.
Date: Thu, 13 Nov 2014 08:57:14 +0100
Message-ID: <CAFqH_50cpvdvCgD-=HQDZ1OT9vmzWkExNHzoASNaruSKLnJZBA@mail.gmail.com>
References: <1415643789-5367-1-git-send-email-eballetbo@iseebcn.com>
	<20141111.183042.469456165241690341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Javier Martinez Canillas <javier@dowhile0.org>,
	Enrico Butera <ebutera@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:44179 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbaKMH5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 02:57:16 -0500
Received: by mail-wi0-f181.google.com with SMTP id n3so7320565wiv.14
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 23:57:14 -0800 (PST)
In-Reply-To: <20141111.183042.469456165241690341.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2014-11-12 0:30 GMT+01:00 David Miller <davem@davemloft.net>:
> From: Enric Balletbo i Serra <eballetbo@iseebcn.com>
> Date: Mon, 10 Nov 2014 19:23:09 +0100
>
>> With commit be9dad1f9f26604fb ("net: phy: suspend phydev when going
>> to HALTED"), the PHY device will be put in a low-power mode using
>> BMCR_PDOWN if the the interface is set down. The smsc911x driver does
>> a software_reset opening the device driver (ndo_open). In such case,
>> the PHY must be powered-up before access to any register and before
>> calling the software_reset function. Otherwise, as the PHY is powered
>> down the software reset fails and the interface can not be enabled
>> again.
>>
>> This patch fixes this scenario that is easy to reproduce setting down
>> the network interface and setting up again.
>>
>>     $ ifconfig eth0 down
>>     $ ifconfig eth0 up
>>     ifconfig: SIOCSIFFLAGS: Input/output error
>>
>> Signed-off-by: Enric Balletbo i Serra <eballetbo@iseebcn.com>
>  ...
>> +             mdelay(1);
>
> As per Javier's feedback, please convert this to usleep_range()
> if you agree that this can only be invoked from process context.
>

Yes, I'm agree. I'll send version 2 of the patch changing this. Also
there are other places that use the mdelay family intead of
usleep_range() and can only be invoked from process context. Maybe
would be interesting send another patch changing this.

Cheers,
   Enric

> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
