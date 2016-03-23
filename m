From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH] at803x: fix reset handling
Date: Wed, 23 Mar 2016 12:56:43 +0100
Message-ID: <56F2847B.5090904@zonque.org>
References: <1525241.UQIRf9ZOB3@wasted.cogentembedded.com>
 <20160323064504.GI6191@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	Daniel Mack <zonque@gmail.com>
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:34931 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751765AbcCWMER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2016 08:04:17 -0400
In-Reply-To: <20160323064504.GI6191@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,
Hi Uwe,

On 03/23/2016 07:45 AM, Uwe Kleine-K=C3=B6nig wrote:
> I added the author of 13a56b449325 to Cc.

Thanks for doing that!

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

Well, the driver asserts the line by setting it to 1, while in fact the
chip itself considers 'low' as 'asserted'. Hence I opted for flipping
the logic in DT rather than in the driver core. IIRC, there was even
some sort of level-shifting inversion going on in our design, but I
don't recall the details.

That said, I don't care much. If the general assumption is to make the
driver calls match the actual output on the peripheral, then fine, let'=
s
turn it around, but that's a matter of interpretation IMO.

>> Fixes: 13a56b449325 ("net: phy: at803x: Add support for hardware res=
et")
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>
>> ---
>> The patch is against DaveM's 'net.git' repo.
>=20
> Don't you need to work against net-next for non-urgent stuff? Or do y=
ou
> consider this urgent?

It's certainly not :)

> The new variant is better than the old one. The change however breaks
> existing device trees which is not so nice. Given there are no mainli=
ne
> users this is probably ok though. So:

Hmm, one idea for DT was to allow for external board support via DTB
files, right? Then again, bindings breaks happen all the time anyway.

As far as I'm concerned, I'm fine with the change. If it lands, I'll
simply give my colleagues a short heads-up so they can flip the bit on
their side too.


Thanks,
Daniel
