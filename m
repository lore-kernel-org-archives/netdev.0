From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: replace macros net_random and net_srandom
 with direct calls to prandom
Date: Sat, 11 Jan 2014 20:29:34 +0100
Message-ID: <52D19B9E.2080501@redhat.com>
References: <1389442559-13097-1-git-send-email-aruna.hewapathirane@gmail.com>  <1389462757.2537.61.camel@joe-AO722>  <20140111180025.GB6586@order.stressinduktion.org>  <52D192FD.90606@redhat.com> <1389468006.2537.72.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Aruna-Hewapathirane <aruna.hewapathirane@gmail.com>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5465 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750879AbaAKT3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Jan 2014 14:29:43 -0500
In-Reply-To: <1389468006.2537.72.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2014 08:20 PM, Joe Perches wrote:
> On Sat, 2014-01-11 at 19:52 +0100, Daniel Borkmann wrote:
>> On 01/11/2014 07:00 PM, Hannes Frederic Sowa wrote:
>>> On Sat, Jan 11, 2014 at 09:52:37AM -0800, Joe Perches wrote:
>>>> On Sat, 2014-01-11 at 07:15 -0500, Aruna-Hewapathirane wrote:
>>>>> This patch removes the net_random and net_srandom macros and replaces
>>>>> them with direct calls to the prandom ones. As new commits only seem to
>>>>> use prandom_u32 there is no use to keep them around.
>>>>> This change makes it easier to grep for users of prandom_u32.
>>>>
>>>> Seems sensible.
>>>>
>>>> Also, there may be some value in a future patch
>>>> to use reciprocal_divide in a few places
>>>>
>>>>> diff --git a/net/802/garp.c b/net/802/garp.c
>>>>> @@ -397,7 +397,7 @@ static void garp_join_timer_arm(struct garp_applicant *app)
>>>>>    {
>>>>>    	unsigned long delay;
>>>>>
>>>>> -	delay = (u64)msecs_to_jiffies(garp_join_time) * net_random() >> 32;
>>>>> +	delay = (u64)msecs_to_jiffies(garp_join_time) * prandom_u32() >> 32;
>>>>
>>>> reciprocal_divide()
>>>
>>> Does reciprocal_divide() make sense without reciprocal_value() from a
>>> stylish point of view?
>>
>> No. ;-)
>>
>> There was already some work, but I didn't have time to finish it:
>>
>> http://www.spinics.net/lists/netdev/msg249395.html
>
> I had forgotten about this.
>
>> Maybe it's time that we should revisit that.
>
> It'd be nice if you found some time to finish it.

Sure, /at latest/ after the merge window, I will get back to that.

Thanks,

Daniel
