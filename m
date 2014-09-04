From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH] ip monitor: Dont print timestamp or banner-label for
 cloned routes
Date: Thu, 4 Sep 2014 22:59:36 +0300
Message-ID: <CAMw6YJJRfBLh0Jft=zCN8tj8wm6qhjoB=NibJwtcn8AqajXmXw@mail.gmail.com>
References: <1409856738-1938-1-git-send-email-vadim4j@gmail.com>
	<5408BD9F.9060107@cogentembedded.com>
	<CAMw6YJL_-6_zXo9tmEz3M8V-CxeoaAN_y0wscDt+JsM8xKkqAw@mail.gmail.com>
	<5408C37C.6050104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:46321 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755194AbaIDT7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 15:59:39 -0400
Received: by mail-qg0-f44.google.com with SMTP id j5so10377510qga.17
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 12:59:36 -0700 (PDT)
In-Reply-To: <5408C37C.6050104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hm thats strange I changed subject of the fixed patch to the [PATCH
v2] form but it appeared in this thread w/o v2.

On Thu, Sep 4, 2014 at 10:54 PM, Vlad Yasevich <vyasevich@gmail.com> wrote:
> On 09/04/2014 03:35 PM, Vadim Kochan wrote:
>> Thanks!
>>
>> Should I re-send the fixed patch with some special subject after
>> comments/review ?
>
> Typically a [PATCH v2] and so on if there are comments on v2.
>
> -vlad
>
>>
>> On Thu, Sep 4, 2014 at 10:29 PM, Sergei Shtylyov
>> <sergei.shtylyov@cogentembedded.com> wrote:
>>> Hello.
>>>
>>>
>>> On 09/04/2014 10:52 PM, Vadim Kochan wrote:
>>>
>>>> This is ugly fix but solves the case when timestamp
>>>> or banner-label is printed before the cloned route will be skipped
>>>> by iproute filter which filters out all cached routes by default.
>>>> In such case timestamp will be printed twice:
>>>
>>>
>>>>      Timestamp: Thu Sep  4 19:46:59 2014 457933 usec
>>>>      Timestamp: Thu Sep  4 19:47:07 2014 977970 usec
>>>>      10.3.5.1 dev wlp3s0 lladdr XX:XX:XX:XX:XX:XX STALE
>>>
>>>
>>>> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
>>>> ---
>>>>   ip/ipmonitor.c | 13 ++++++++++---
>>>>   1 file changed, 10 insertions(+), 3 deletions(-)
>>>
>>>
>>>> diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
>>>> index 70f2a7a..2bd3fed 100644
>>>> --- a/ip/ipmonitor.c
>>>> +++ b/ip/ipmonitor.c
>>>
>>> [...]
>>>
>>>> @@ -53,6 +50,12 @@ static int accept_msg(const struct sockaddr_nl *who,
>>>>                         return -1;
>>>>                 }
>>>>
>>>> +               if (r->rtm_flags&RTM_F_CLONED)
>>>
>>>
>>>    Judging on the patched code, spaces are needed around &.
>>>
>>>
>>>> +                       return 0;
>>>> +
>>>> +               if (timestamp)
>>>> +                       print_timestamp(fp);
>>>> +
>>>>                 if (r->rtm_family == RTNL_FAMILY_IPMR ||
>>>>                     r->rtm_family == RTNL_FAMILY_IP6MR) {
>>>>                         if (prefix_banner)
>>>
>>> [...]
>>>
>>> WBR, Sergei
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
