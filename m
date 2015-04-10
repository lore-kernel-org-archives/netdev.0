From: Mason <slash.tmp@free.fr>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is
 commented out
Date: Fri, 10 Apr 2015 12:01:09 +0200
Message-ID: <55279F65.9090202@free.fr>
References: <5525571D.7060909@free.fr> <5525658D.7000709@gmail.com> <5526662C.8010509@free.fr> <5526806E.5020309@zonque.org> <55268EF3.7050301@free.fr> <5526993F.1010304@free.fr> <5526B608.2080504@gmail.com> <5526CA87.2070204@free.fr> <5526CC5A.1080504@gmail.com> <5526D359.1050202@free.fr> <552798CD.70608@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Daniel Mack <daniel@zonque.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:57601 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753722AbbDJKBT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 06:01:19 -0400
In-Reply-To: <552798CD.70608@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Mack wrote:

> Mason wrote:
>
>> Am I the only having problems with the AR8035? :-(
>> The standard driver works for everyone but me?
>
> A company I used to work with ships various hardware models in
> quantities which features this chip, and they're using the unpatched
> mainline kernel version of the driver.

It seems something was done differently on my SoC.
I'll keep looking.

>> Did you take a look at the data sheet? Do you understand the
>> difference between "Hardware Reset" and "Software Reset"?
>
> I did, most notably because I was desperately trying to find a sane way
> to conduct a full reset of the PHY to work around a confirmed bug in the
> DIE of the chip which causes the internal state machine to lock up on
> link loss under certain conditions.
>
> Unfortunately, I failed to find a way to really put the chip into
> complete reset state through the registers. Instead, I added a
> possibility to let the driver pull the hardware reset (see 13a56b4493).
>
> Other than that, however, I didn't encounter any problems.

I wonder what value the CONTROL register was set to on your SoC
after a SW reset. Maybe the "retain value" jiggery-pokery is just
a red herring.

>> Maybe on my PHY, writing BMCR_RESET to BMCR triggers a SW reset,
>> while it triggers a HW reset on other boards?
>
> AFAIK, the chip does not do this, no. But even if it did,

Did you forget to finish that sentence? :-)


>> Also, why do you say the PHY is not working? When I apply the
>> patch I proposed, it doesn't malfunction.
>
> You're referring to the one that removes the phy init routine?

No, the RMW of the CONTROL register for when triggering reset.

> I'd still go and check if there's anything in one of the chained
> bootloaders that does some magic. One other thing that might give you a
> hint is to manually pull the RESET line low for a short time right when
> the kernel decompressor is started. That way, the kernel has to deal
> with a device that has just seen a hardware reset. Just see if that
> makes any difference.

I'd force a HW reset by jiggling the appropriate GPIO pin?
Like you did in the at803x.c driver?

> Also, some delays in between the register writes during initialization
> might also be worth a try. But that's all just random guessing right
> now, sorry.

Thanks for your help, by the way (and Fabio too).

Regards.
