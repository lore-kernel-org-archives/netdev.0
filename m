From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [RFC] gianfar: low gigabit throughput
Date: Wed, 7 May 2008 17:33:46 +0400
Message-ID: <20080507133346.GA8308@polina.dev.rtsoft.ru>
References: <20080506192008.GA30148@polina.dev.rtsoft.ru> <4820BA72.3090903@hp.com> <E82C3C5F-0D93-4190-ADDC-3FA37D13E250@freescale.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:51186 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1751966AbYEGNdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 09:33:49 -0400
Content-Disposition: inline
In-Reply-To: <E82C3C5F-0D93-4190-ADDC-3FA37D13E250@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 06, 2008 at 03:29:06PM -0500, Andy Fleming wrote:
>>>
>>> I've tried to tune gianfar driver in various ways... and it gave
>>> some positive results with this patch:
>>> diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
>>> index fd487be..b5943f9 100644
>>> --- a/drivers/net/gianfar.h
>>> +++ b/drivers/net/gianfar.h
>>> @@ -123,8 +123,8 @@ extern const char gfar_driver_version[];
>>> #define GFAR_10_TIME    25600
>>>  #define DEFAULT_TX_COALESCE 1
>>> -#define DEFAULT_TXCOUNT	16
>>> -#define DEFAULT_TXTIME	21
>>> +#define DEFAULT_TXCOUNT	80
>>> +#define DEFAULT_TXTIME	105
>>>  #define DEFAULT_RXTIME	21
>>
>> No ethtool coalescing tuning support for gianfar?-)
>
> Yeah, there's coalescing tuning in gianfar.
>
> Anton, those numbers aren't too surprising on a 400 MHz machine, I  
> think.

This is my thinking too, actually. I've seen the MPC885 board with CPU
running at 133 MHz and CSB at 66MHz. It was using the completely
different driver (fs_enet's FEC), and it failed to produce even 60 Mb/s
(with a 100 Mb/s PHY). 50-55 Mb/s was quite normal for that board.

Which means, I think, that ~160 Mb/s is quite good for the 400/133
MHz board.

> But I'd be happy to see any analysis on performance bottlenecks 
> in the driver.  And patches to fix those bottlenecks are even better!  :)

The thing is that I don't see obvious bottlenecks, so I'm afraid we'll
not able to do x2 boost or something... Just fine tuning the driver here
and there... Interrupts coalescing was very obvious step to boost the
troughtput, but there are its drawbacks...

Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
