From: Glauber Costa <glommer@parallels.com>
Subject: Re: [BUGFIX][PATCH 3/3] memcg/tcp: ignore tcp usage before accounting
 started
Date: Sun, 8 Apr 2012 22:44:46 -0300
Message-ID: <4F823F0E.40309@parallels.com>
References: <4F7408B7.9090706@jp.fujitsu.com> <4F740AEF.7090900@jp.fujitsu.com> <4F742983.1080402@parallels.com> <20120401.234113.1505269982606203786.davem@davemloft.net> <4F7B7A54.9000501@parallels.com> <4F823443.9070908@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<akpm@linux-foundation.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:34489 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919Ab2DIBqX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Apr 2012 21:46:23 -0400
In-Reply-To: <4F823443.9070908@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2012 09:58 PM, KAMEZAWA Hiroyuki wrote:
> (2012/04/04 7:31), Glauber Costa wrote:
>
>> On 04/02/2012 07:41 AM, David Miller wrote:
>>> From: Glauber Costa<glommer@parallels.com>
>>> Date: Thu, 29 Mar 2012 11:21:07 +0200
>>>
>>>> On 03/29/2012 09:10 AM, KAMEZAWA Hiroyuki wrote:
>>>>> tcp memcontrol starts accouting after res->limit is set. So, if a sockets
>>>>> starts before setting res->limit, there are already used resource.
>>>>> After setting res->limit, the resource (already used) will be uncharged and
>>>>> make res_counter below 0 because they are not charged. This causes warning.
>>>>>
>>>>> This patch fixes that by adding res_counter_uncharge_nowarn().
>>>>> (*) We cannot avoid this while we have 'account start' switch.
>>>>>
>>>>> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>>>>
>>>> Fine by me.
>>>>
>>>> Acked-by: Glauber Costa<glommer@parallels.com>
>>>
>>> I'm not applying patches that simply ignore accounting counter
>>> underflows.
>>>
>>> You must either:
>>>
>>> 1) Integrate the socket's existing usage when the limit is set.
>>>
>>> 2) Avoid accounting completely for a socket that started before
>>>      the limit was set.
>>>
>>> No half-way solutions, please.  Otherwise it is impossible to design
>>> validations of the resource usage for a particular socket or group of
>>> sockets, because they can always be potentially "wrong" and over the
>>> limit.  That's a design for a buggy system.
>>>
>>>
>> Kame,
>>
>> I agree with Dave FWIW.
>>
>> We should be able to do this by dropping the reference count when the
>> cgroup is finally destroyed, instead of from the remove callback. At
>> that point, no more pending sockets should be attached to it.
>>
>> Prior to increasing the static key, they are all assigned to the global
>> cgroup, so we shouldn't care about them.
>>
>
> Could you do the fix ?
>
> Thanks,
> -Kame
>
>
I sent you a version already. Please just make sure it works for you
