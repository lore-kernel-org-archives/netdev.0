From: Daniel Mack <daniel@zonque.org>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is commented
 out
Date: Fri, 10 Apr 2015 11:33:01 +0200
Message-ID: <552798CD.70608@zonque.org>
References: <5525571D.7060909@free.fr> <5525658D.7000709@gmail.com> <5526662C.8010509@free.fr> <5526806E.5020309@zonque.org> <55268EF3.7050301@free.fr> <5526993F.1010304@free.fr> <5526B608.2080504@gmail.com> <5526CA87.2070204@free.fr> <5526CC5A.1080504@gmail.com> <5526D359.1050202@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Mason <slash.tmp@free.fr>, Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:49269 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754422AbbDJJdE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 05:33:04 -0400
In-Reply-To: <5526D359.1050202@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2015 09:30 PM, Mason wrote:> Am I the only having problems with
the AR8035? :-(
>
> The standard driver works for everyone but me?

A company I used to work with ships various hardware models in
quantities which features this chip, and they're using the unpatched
mainline kernel version of the driver.

> Did you take a look at the data sheet? Do you understand the
> difference between "Hardware Reset" and "Software Reset"?

I did, most notably because I was desperately trying to find a sane way
to conduct a full reset of the PHY to work around a confirmed bug in the
DIE of the chip which causes the internal state machine to lock up on
link loss under certain conditions.

Unfortunately, I failed to find a way to really put the chip into
complete reset state through the registers. Instead, I added a
possibility to let the driver pull the hardware reset (see 13a56b4493).

Other than that, however, I didn't encounter any problems.

> Maybe on my PHY, writing BMCR_RESET to BMCR triggers a SW reset,
> while it triggers a HW reset on other boards?

AFAIK, the chip does not do this, no. But even if it did,

> Also, why do you say the PHY is not working? When I apply the
> patch I proposed, it doesn't malfunction.

You're referring to the one that removes the phy init routine?

I'd still go and check if there's anything in one of the chained
bootloaders that does some magic. One other thing that might give you a
hint is to manually pull the RESET line low for a short time right when
the kernel decompressor is started. That way, the kernel has to deal
with a device that has just seen a hardware reset. Just see if that
makes any difference.

Also, some delays in between the register writes during initialization
might also be worth a try. But that's all just random guessing right
now, sorry.


Daniel
