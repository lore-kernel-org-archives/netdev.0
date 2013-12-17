From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH] ipv6: clear RTF_EXPIRES when call ip6_rt_copy
Date: Tue, 17 Dec 2013 14:42:01 +0800
Message-ID: <CAJFZqHxawisUbHGZY8mjGHy8035X6TQ7FNzc20vtS5j1jdZYGA@mail.gmail.com>
References: <1387182666-31301-1-git-send-email-roy.qing.li@gmail.com>
	<52AFC43C.9080804@cn.fujitsu.com>
	<CAJFZqHwF0ubvxJOs2BWbSMMB1szKNO=XTiXje3E2ByF6sUQrXA@mail.gmail.com>
	<52AFE7E3.3070806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f43.google.com ([209.85.212.43]:40478 "EHLO
	mail-vb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511Ab3LQGmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 01:42:03 -0500
Received: by mail-vb0-f43.google.com with SMTP id p6so3803833vbe.2
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 22:42:02 -0800 (PST)
In-Reply-To: <52AFE7E3.3070806@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/13, Gao feng <gaofeng@cn.fujitsu.com> wrote:
> On 12/17/2013 11:32 AM, RongQing Li wrote:
>> If the ort->rt6i_flags is RTF_EXPIRES|RTF_ADDRCONF, then rt6_set_from will
>> not
>> be called, and new created rt will have RTF_EXPIRES, but dst.expires is 0,
>> and
>> dst.from is NULL
>
> Ok, but I think you need to add more detail/test purpose of the test case
> v6LC.4.1.4
> { Reduce PMTU On-link }. just the number of test case is not good for people
> to know
> what's the real problem.
>

I have a question, why does we set dst.from only when the ort has flag
RTF_ADDRCONF
and RTF_DEFAULT?

-Roy


>>
>> -Roy
>>
>> 2013/12/17 Gao feng <gaofeng@cn.fujitsu.com>:
>>> On 12/16/2013 04:31 PM, roy.qing.li@gmail.com wrote:
>>>> From: Li RongQing <roy.qing.li@gmail.com>
>>>>
>>>> The commit ecd9883724b [ipv6: fix race condition regarding dst->expires
>>>> and
>>>> dst->from.] removed rt6_clean_expires in ip6_rt_copy, which causes the
>>>> TAHI
>>>> test case v6LC.4.1.4 { Reduce PMTU On-link } failed, since the newly
>>>> generated
>>>> rt maybe always expired {with RTF_EXPIRES flag, dst.expires is 0, and
>>>> dst.from
>>>> is NULL}.
>>>>
>>>> Fix it by clearing RTF_EXPIRES as before 1716a96101[ipv6: fix problem
>>>> with
>>>> expired dst cache]
>>>>
>>>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>>>> ---
>>>>  net/ipv6/route.c |    2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>>>> index a1a5752..e3d7f21 100644
>>>> --- a/net/ipv6/route.c
>>>> +++ b/net/ipv6/route.c
>>>> @@ -1908,7 +1908,7 @@ static struct rt6_info *ip6_rt_copy(struct
>>>> rt6_info *ort,
>>>>                       rt->rt6i_gateway = ort->rt6i_gateway;
>>>>               else
>>>>                       rt->rt6i_gateway = *dest;
>>>> -             rt->rt6i_flags = ort->rt6i_flags;
>>>> +             rt->rt6i_flags = ort->rt6i_flags & ~RTF_EXPIRES;
>>>>               if ((ort->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) ==
>>>>                   (RTF_DEFAULT | RTF_ADDRCONF))
>>>>                       rt6_set_from(rt, ort);
>>>>
>>>
>>> I don't understand, rt6_set_from already clears the RTF_EXPIRES from
>>> rt->rt6i_flags.
>>>
>>
>
>
