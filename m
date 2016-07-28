From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 0/2] net: davinci_cpdma: reduce latency on -rt
Date: Thu, 28 Jul 2016 12:34:19 +0300
Message-ID: <fc2a3300-4f6b-aff7-995d-77b37bdaab65@ti.com>
References: <1469534545-14478-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <f546b5f0-1da6-2c16-647a-33bb8692b753@ti.com>
 <20160727070302.GG5368@pengutronix.de>
 <076e6aa6-91f3-8707-1d8b-504c4962f7cd@ti.com>
 <20160727143804.GC5629@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mugunthan V N <mugunthanvnm@ti.com>, <linux-omap@vger.kernel.org>,
	<netdev@vger.kernel.org>, <kernel@pengutronix.de>
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:53048 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442AbcG1Jec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 05:34:32 -0400
In-Reply-To: <20160727143804.GC5629@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/27/2016 05:38 PM, Uwe Kleine-K=F6nig wrote:
> Hello,
>=20
> On Wed, Jul 27, 2016 at 05:11:54PM +0300, Grygorii Strashko wrote:
>> On 07/27/2016 10:03 AM, Uwe Kleine-K=F6nig wrote:
>>> On Tue, Jul 26, 2016 at 05:36:49PM +0300, Grygorii Strashko wrote:
>>>> On 07/26/2016 03:02 PM, Uwe Kleine-K=F6nig wrote:
>>>>> Hello,
>>>>>
>>>>> these patches are based on next-20160726. I didn't check yet how =
latency
>>>>> improves by using these patches, but even if the improvment is sm=
all,
>>>>> it's still a good idea to have them.
>>>>
>>>> Sry, but how this will affect on -RT? This is not a raw locks, so
>>>> they will be converted to rt-mutexes which are sleepable.
>>>> Or I've missed smth?
>>>
>>> They are still locks after all. On -rt I saw for the relevant
>>> application:
>>>
>>>   send package         |
>>>     take lock          |
>>>     write pckt to hw   |
>>>                        | rcv irq
>>> 		       |   take lock
>>> 		       |     schedule
>>>     drop lock	       |=20
>>>       schedule         |
>>>                        |   get pckt from hw
>>> 		       |   drop lock
>>>
>>> So reducing the time a lock is taken reduces the chances that the l=
ock
>>> is contended for another thread which results in extra context swit=
ches.
>>>
>> Thanks a lot for explanation. So, this is not exactly rt-latency red=
uction,
>> but it might improve net performance on -RT. correct?
>=20
> Well, it's not really rt related, but if you hit a locked lock on rt =
it
> hurts more than on !rt. And this results in increased latency.
>=20

Thanks. I've just wanted to have clear understanding of the [possible] =
issue.
And I'd be appreciated if you could share and measurement results if yo=
u have.

--=20
regards,
-grygorii
