From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: replace macros net_random and net_srandom
 with direct calls to prandom
Date: Sat, 11 Jan 2014 19:52:45 +0100
Message-ID: <52D192FD.90606@redhat.com>
References: <1389442559-13097-1-git-send-email-aruna.hewapathirane@gmail.com> <1389462757.2537.61.camel@joe-AO722> <20140111180025.GB6586@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Aruna-Hewapathirane <aruna.hewapathirane@gmail.com>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12262 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753260AbaAKSwy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Jan 2014 13:52:54 -0500
In-Reply-To: <20140111180025.GB6586@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2014 07:00 PM, Hannes Frederic Sowa wrote:
> On Sat, Jan 11, 2014 at 09:52:37AM -0800, Joe Perches wrote:
>> On Sat, 2014-01-11 at 07:15 -0500, Aruna-Hewapathirane wrote:
>>> This patch removes the net_random and net_srandom macros and replaces
>>> them with direct calls to the prandom ones. As new commits only seem to
>>> use prandom_u32 there is no use to keep them around.
>>> This change makes it easier to grep for users of prandom_u32.
>>
>> Seems sensible.
>>
>> Also, there may be some value in a future patch
>> to use reciprocal_divide in a few places
>>
>>> diff --git a/net/802/garp.c b/net/802/garp.c
>>> @@ -397,7 +397,7 @@ static void garp_join_timer_arm(struct garp_applicant *app)
>>>   {
>>>   	unsigned long delay;
>>>
>>> -	delay = (u64)msecs_to_jiffies(garp_join_time) * net_random() >> 32;
>>> +	delay = (u64)msecs_to_jiffies(garp_join_time) * prandom_u32() >> 32;
>>
>> reciprocal_divide()
>
> Does reciprocal_divide() make sense without reciprocal_value() from a
> stylish point of view?

No. ;-)

There was already some work, but I didn't have time to finish it:

http://www.spinics.net/lists/netdev/msg249395.html

Maybe it's time that we should revisit that.

> I wouldn't do that just because it expands into the same code.
>
> Greetings,
>
>    Hannes
