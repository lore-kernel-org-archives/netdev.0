From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH stable v3.2 v3.4] ipv4: disable bh while doing route gc
Date: Tue, 21 Oct 2014 17:51:56 -0200
Message-ID: <5446B95C.5040206@redhat.com>
References: <6c3d6eca5d6a15c01393b010f2116bd169477c5a.1413215324.git.mleitner@redhat.com>		 <20141013.135127.1915115817707962111.davem@davemloft.net>	 <1413774581.31953.12.camel@decadent.org.uk> <5446AF2A.1030508@redhat.com> <1413919971.31953.39.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	netdev@vger.kernel.org, hannes@stressinduktion.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1413919971.31953.39.camel@decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21-10-2014 17:32, Ben Hutchings wrote:
> On Tue, 2014-10-21 at 17:08 -0200, Marcelo Ricardo Leitner wrote:
>> On 20-10-2014 01:09, Ben Hutchings wrote:
>>> On Mon, 2014-10-13 at 13:51 -0400, David Miller wrote:
>>>> From: Marcelo Ricardo Leitner <mleitner@redhat.com>
>>>> Date: Mon, 13 Oct 2014 14:03:30 -0300
>>>>
>>>>> Further tests revealed that after moving the garbage collector to a work
>>>>> queue and protecting it with a spinlock may leave the system prone to
>>>>> soft lockups if bottom half gets very busy.
>>>>>
>>>>> It was reproced with a set of firewall rules that REJECTed packets. If
>>>>> the NIC bottom half handler ends up running on the same CPU that is
>>>>> running the garbage collector on a very large cache, the garbage
>>>>> collector will not be able to do its job due to the amount of work
>>>>> needed for handling the REJECTs and also won't reschedule.
>>>>>
>>>>> The fix is to disable bottom half during the garbage collecting, as it
>>>>> already was in the first place (most calls to it came from softirqs).
>>>>>
>>>>> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
>>>>> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>>>> Acked-by: David S. Miller <davem@davemloft.net>
>>>>> Cc: stable@vger.kernel.org
>>>>
>>>> -stable folks, please integrate this directly, thanks!
>>>
>>> I've appplied this and the previous two patches mentioned ('ipv4: move
>>> route garbage collector to work queue' and 'ipv4: avoid parallel route
>>> cache gc executions').  But I didn't get the other two from you.  The
>>> last batch of networking fixes I received and applied was dated
>>> 2014-08-07, and the next one I've seen is dated 2014-10-11 and has
>>> nothing for 3.2 or 3.4.  Did I miss one between these?
>>
>> Sorry to ask Ben but, where did you apply them? I'm not seeing the commits on
>> linux-stable.git and couldn't find their summaries anywhere else.
>
> They're in a patch queue that I've just pushed to:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/bwh/linux-3.2.y-queue.git

Cool, thanks!

Marcelo
