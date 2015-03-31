From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: at803x: simplify using
 devm_gpiod_get_optional and its 4th argument
Date: Tue, 31 Mar 2015 14:07:00 -0400 (EDT)
Message-ID: <20150331.140700.1574593248925827837.davem@davemloft.net>
References: <1427484302-17075-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<20150331.125754.1434513759096073981.davem@davemloft.net>
	<20150331175347.GL17728@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linus.walleij@linaro.org, acourbot@nvidia.com
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49143 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458AbbCaSHD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 14:07:03 -0400
In-Reply-To: <20150331175347.GL17728@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Tue, 31 Mar 2015 19:53:47 +0200

> On Tue, Mar 31, 2015 at 12:57:54PM -0400, David Miller wrote:
>> 1) It potentially leaves an error pointer in priv->gpiod_reset
>>    and I explicitly tell people to NEVER do this as it tests as
>>    non-NULL by cleanup code and therefore might be mistakenly
>>    used.
> If priv->gpiod_reset is an error value it makes the probe routine ret=
urn
> this error (after point 2 is addressed), which should end the lifetim=
e
> of the structure containing the value.

It doesn't matter, it's a dangerous practice and not doing so makes
sure that no matter how this code is ever changed nobody can run into
potential problems due to this.

>> I really hate changes like this, don't try to be too cute unless
>> you fully understand the full repurcussions and the reasons why
>> someone did things one way or another.
> I think I did understand the code, so I will resend with
> PTR_ERR_OR_ZERO assuming it was you who didn't understood my change
> regarding the other two issues you pointed out.

I'm not applying this patch if you keep putting error pointers into
the structure member.

Please do not fight me on this, I do not consider your changes an
improvement at all.
