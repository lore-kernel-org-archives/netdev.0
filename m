From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] at803x: fix reset handling
Date: Wed, 23 Mar 2016 16:23:28 +0300
Message-ID: <56F298D0.4080200@cogentembedded.com>
References: <1525241.UQIRf9ZOB3@wasted.cogentembedded.com>
 <20160323064504.GI6191@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	Daniel Mack <zonque@gmail.com>
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:36832 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487AbcCWNXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 09:23:34 -0400
Received: by mail-lb0-f171.google.com with SMTP id qe11so9688325lbc.3
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 06:23:33 -0700 (PDT)
In-Reply-To: <20160323064504.GI6191@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/23/2016 09:45 AM, Uwe Kleine-K=F6nig wrote:

> On Wed, Mar 23, 2016 at 12:44:40AM +0300, Sergei Shtylyov wrote:
>> The driver of course "knows" that the chip's reset signal is active =
low,
>> so  it drives the GPIO to 0  to reset the PHY and to 1 otherwise; ho=
wever
>> all this will only work iff the GPIO  is  specified as active-high i=
n the
>> device tree!  I think both the driver and the device trees (if there=
 are
>> any -- I was unable to find them) need to be fixed in this case...
>>
>> Fixes: 13a56b449325 ("net: phy: at803x: Add support for hardware res=
et")
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>
>> ---
>> The patch is against DaveM's 'net.git' repo.
>
> Don't you need to work against net-next for non-urgent stuff? Or do y=
ou
> consider this urgent?

    The net-next.git is not for fixes, net.git is. And net-next is clos=
ed=20
right now because of the merge window.

>>   drivers/net/phy/at803x.c |    6 +++---
>>   1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> Index: net/drivers/net/phy/at803x.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- net.orig/drivers/net/phy/at803x.c
>> +++ net/drivers/net/phy/at803x.c
>> @@ -277,7 +277,7 @@ static int at803x_probe(struct phy_devic
>>   	if (!priv)
>>   		return -ENOMEM;
>>
>> -	gpiod_reset =3D devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_HI=
GH);
>> +	gpiod_reset =3D devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_LO=
W);
>>   	if (IS_ERR(gpiod_reset))
>>   		return PTR_ERR(gpiod_reset);
>>
>> @@ -362,10 +362,10 @@ static void at803x_link_change_notify(st
>>
>>   				at803x_context_save(phydev, &context);
>>
>> -				gpiod_set_value(priv->gpiod_reset, 0);
>> -				msleep(1);
>>   				gpiod_set_value(priv->gpiod_reset, 1);
>>   				msleep(1);
>> +				gpiod_set_value(priv->gpiod_reset, 0);
>> +				msleep(1);
>
> The new variant is better than the old one. The change however breaks
> existing device trees which is not so nice. Given there are no mainli=
ne
> users this is probably ok though. So:
>
> Acked-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

    Thank you!

MBR, Sergei
