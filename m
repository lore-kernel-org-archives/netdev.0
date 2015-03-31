From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH RFC v2 1/2] can: fix multiple delivery of a single CAN
 frame for overlapping CAN filters
Date: Tue, 31 Mar 2015 22:24:20 +0200
Message-ID: <551B0274.1010900@hartkopp.net>
References: <1427652564-32181-1-git-send-email-socketcan@hartkopp.net> <1427652564-32181-2-git-send-email-socketcan@hartkopp.net> <5519210E.40005@pengutronix.de> <55192872.7000108@hartkopp.net> <551A93D0.6000302@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.217]:35207 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064AbbCaUYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 16:24:31 -0400
In-Reply-To: <551A93D0.6000302@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31.03.2015 14:32, Marc Kleine-Budde wrote:
> On 03/30/2015 12:41 PM, Oliver Hartkopp wrote:
>> Please check out
>>
>> https://www.kernel.org/pub/linux/kernel/people/rusty/kernel-locking/
>>
>> And especially
>> https://www.kernel.org/pub/linux/kernel/people/rusty/kernel-locking/x173.html#LOCK-SOFTIRQS-SAME
>>
>> When a softirq processes an incoming skb this remains on that selected CPU.
>
> Okay, I was not sure about this. What about preempt_rt?
>

I don't care :-)

There are so many implementations that rely on this per-CPU stuff that we can 
assume preempt_rt takes care of it (e.g. with locking or reducing CPU cores, etc)

>> Putting a struct into these percpu handling can be done - but does it increase
>> the readability in this case?
>
> It saves ressources, 1 pointer instead of 3 (considering both of your
> patches) and only 1 allocation.

Yes. I did some more code reading, created a struct for it and omitted the 
initialization as alloc_percpu returns an already zero'ed memory region.

Will send tomorrow morning.

Regards,
Oliver
