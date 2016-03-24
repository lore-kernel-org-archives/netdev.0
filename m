From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH] net: phy: at803x: Request 'reset' GPIO only for AT8030
 PHY
Date: Thu, 24 Mar 2016 10:55:46 +0100
Message-ID: <56F3B9A2.9060801@laposte.net>
References: <56E99727.9040702@laposte.net> <20160318125455.GN4292@pengutronix.de> <56EC2525.8000706@laposte.net> <20160318191242.GQ4292@pengutronix.de> <56EFEDAD.9030903@laposte.net> <20160321135457.GX4292@pengutronix.de> <56F0150F.8080804@laposte.net> <20160321201229.GA6191@pengutronix.de> <56F157EF.5080307@laposte.net> <20160322194224.GF6191@pengutronix.de> <56F26BF7.3090201@laposte.net> <56F274A5.6030502@laposte.net> <56F2F189.1030003@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	=?windows-1252?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz26.laposte.net ([194.117.213.101]:56745 "EHLO
	smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755189AbcCXJzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 05:55:50 -0400
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout014 (Postfix) with ESMTP id C279C11F24B
	for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 10:55:47 +0100 (CET)
Received: from lpn-prd-vrin001 (lpn-prd-vrin001.prosodie [10.128.63.2])
	by lpn-prd-vrout014 (Postfix) with ESMTP id A674B11EE1D
	for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 10:55:47 +0100 (CET)
Received: from lpn-prd-vrin001 (localhost [127.0.0.1])
	by lpn-prd-vrin001 (Postfix) with ESMTP id 74F9D36542B
	for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 10:55:47 +0100 (CET)
In-Reply-To: <56F2F189.1030003@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

On 03/23/2016 08:42 PM, Sergei Shtylyov wrote:
> Hello.
> 
> On 03/23/2016 01:49 PM, Sebastian Frias wrote:
> 
>> This removes the dependency on GPIOLIB for non faulty PHYs.
>>
>> Indeed, without this patch, if GPIOLIB is not selected
>> devm_gpiod_get_optional() will return -ENOSYS and the driver probe
>> call will fail, regardless of the actual PHY hardware.
>>
>> Out of the 3 PHYs supported by this driver (AT8030, AT8031, AT8035),
>> only AT8030 presents the issues that commit 13a56b449325 ("net: phy:
>> at803x: Add support for hardware reset") attempts to work-around by
>> using a 'reset' GPIO line.
>>
>> Hence, only AT8030 should depend on GPIOLIB operating properly.
>>
>> Fixes: 13a56b449325 ("net: phy: at803x: Add support for hardware reset")
>>
>> Signed-off-by: Sebastian Frias <sf84@laposte.net>
> [...]
> 
>    What I don't understand is why the link_change_notify() method ptr is
> populated for all 3 supported chips while only being needed on 8030...

You are right.
I had commented on that here
https://marc.info/?l=linux-netdev&m=145856582932498&w=2

<quote>
Furthermore, I think we should not even register the
"link_change_notify" callback when dealing with AT803x PHYs that do not
require the hack.
Another solution (considering the callback is statically registered in
the "phy_driver" structs for all AT803x PHYs) would be for the callback
to disable itself.
</quote>

I was waiting for comments from the original implementor.

However, I guess we can remove them as well.
I will make another patch.

Best regards,

Sebastian
