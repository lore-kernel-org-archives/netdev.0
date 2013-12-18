From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: clear RTF_EXPIRES when call ip6_rt_copy
Date: Wed, 18 Dec 2013 16:40:04 +0800
Message-ID: <52B15F64.4070303@cn.fujitsu.com>
References: <CAJFZqHwF0ubvxJOs2BWbSMMB1szKNO=XTiXje3E2ByF6sUQrXA@mail.gmail.com> <52AFE7E3.3070806@cn.fujitsu.com> <CAJFZqHxawisUbHGZY8mjGHy8035X6TQ7FNzc20vtS5j1jdZYGA@mail.gmail.com> <20131217070231.GA11970@order.stressinduktion.org> <52B00150.3070002@cn.fujitsu.com> <20131217134823.GC18396@order.stressinduktion.org> <52B0F0C4.1010803@cn.fujitsu.com> <CAJFZqHywaN4k64zd-fcw7=DD+6iNX_Psuwi2QKH_GX-_04TVSg@mail.gmail.com> <52B103DE.7090604@cn.fujitsu.com> <CAJFZqHxB8PscqXnX9oxpHf8zFyW1hyCZVZTn_=DoKebN3X2ZGA@mail.gmail.com> <20131218062000.GC27460@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: RongQing Li <roy.qing.li@gmail.com>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:15880 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751158Ab3LRIjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 03:39:13 -0500
In-Reply-To: <20131218062000.GC27460@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/18/2013 02:20 PM, Hannes Frederic Sowa wrote:
> On Wed, Dec 18, 2013 at 10:21:12AM +0800, RongQing Li wrote:
>> On Wed, Dec 18, 2013 at 10:09 AM, Gao feng <gaofeng@cn.fujitsu.com> wrote:
>>> On 12/18/2013 09:58 AM, RongQing Li wrote:
>>>> On Wed, Dec 18, 2013 at 8:48 AM, Gao feng <gaofeng@cn.fujitsu.com> wrote:
>>>>> On 12/17/2013 09:48 PM, Hannes Frederic Sowa wrote:
>>>>>> On Tue, Dec 17, 2013 at 03:46:24PM +0800, Gao feng wrote:
>>>>>>> The from of new cloned rt should not be set if it's impossible for the ort
>>>>>>> to be expired.
>>>>>>
>>>>>> Actually, why do you think so? What could go wrong?
>>>>>>
>>>>>
>>>>> I just don't want rt6_check_expired to check some impossible expired routes.
>>>>>
>>>>
>>>> What is wrong if we set from for new cloned rt by checking if ort has
>>>> RTF_EXPIRES flag?
>>>
>>>
>>> The RTF_EXPIRES flag may be changed by router advertisment package,
>>> the ort may become expired after you hadn't set from for new cloned rt.
>>>
>>> we should set from even this kind of ort doesn't have RTF_EXPIRES flag.
>>
>>
>> Thanks;
>>
>> Do we want to set from only from RA route?  if so,  we should check
>> ort with RTF_ADDRCONF|RTF_DEFAULT, or RTF_ADDRCONF | RTF_ROUTEINFO,
> 
> Nope, as I said, also prefix routes which did get installed by hand locally
> can have an expiration. I don't see any flag combination which ensure a
> potential from does never expire. IMHO we should always from.
> 
> Also, in case we overwrite a route and the route is already in there, we reset
> the expiry values: search for rt6_set_expires in fib6_add_rt2node.

Seem like user can add expired route by manually. rtmsg_to_fib6_config set the
cfg->fc_expires. I'm ok if you want to set from always now.

Thanks
