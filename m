From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 0/2] net: davinci_cpdma: reduce latency on -rt
Date: Wed, 27 Jul 2016 17:11:54 +0300
Message-ID: <076e6aa6-91f3-8707-1d8b-504c4962f7cd@ti.com>
References: <1469534545-14478-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <f546b5f0-1da6-2c16-647a-33bb8692b753@ti.com>
 <20160727070302.GG5368@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mugunthan V N <mugunthanvnm@ti.com>, <linux-omap@vger.kernel.org>,
	<netdev@vger.kernel.org>, <kernel@pengutronix.de>
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([198.47.19.11]:41130 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214AbcG0OMF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2016 10:12:05 -0400
In-Reply-To: <20160727070302.GG5368@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/27/2016 10:03 AM, Uwe Kleine-K=F6nig wrote:
> On Tue, Jul 26, 2016 at 05:36:49PM +0300, Grygorii Strashko wrote:
>> On 07/26/2016 03:02 PM, Uwe Kleine-K=F6nig wrote:
>>> Hello,
>>>
>>> these patches are based on next-20160726. I didn't check yet how la=
tency
>>> improves by using these patches, but even if the improvment is smal=
l,
>>> it's still a good idea to have them.
>>
>> Sry, but how this will affect on -RT? This is not a raw locks, so
>> they will be converted to rt-mutexes which are sleepable.
>> Or I've missed smth?
>=20
> They are still locks after all. On -rt I saw for the relevant
> application:
>=20
>   send package         |
>     take lock          |
>     write pckt to hw   |
>                        | rcv irq
> 		       |   take lock
> 		       |     schedule
>     drop lock	       |=20
>       schedule         |
>                        |   get pckt from hw
> 		       |   drop lock
>=20
> So reducing the time a lock is taken reduces the chances that the loc=
k
> is contended for another thread which results in extra context switch=
es.
>=20
Thanks a lot for explanation. So, this is not exactly rt-latency reduct=
ion,
but it might improve net performance on -RT. correct?

Thanks.
--=20
regards,
-grygorii
