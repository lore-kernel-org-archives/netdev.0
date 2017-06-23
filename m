From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [Patch net] sit: use __GFP_NOWARN for user controlled allocation
Date: Fri, 23 Jun 2017 14:22:24 +0200
Message-ID: <CAAeHK+wjtUM4BWRUsG+1Ck0S-9LJLw0p6Bc3yiW0J_H8NPFyUw@mail.gmail.com>
References: <1498170573-24082-1-git-send-email-xiyou.wangcong@gmail.com> <CAAeHK+yshaEMc0oR-jCFR-m_9dSOFK8U7v_8EUa-0M1W5qFxuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f171.google.com ([209.85.213.171]:33683 "EHLO
        mail-yb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751201AbdFWMWZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 08:22:25 -0400
Received: by mail-yb0-f171.google.com with SMTP id 84so12753751ybe.0
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2017 05:22:25 -0700 (PDT)
In-Reply-To: <CAAeHK+yshaEMc0oR-jCFR-m_9dSOFK8U7v_8EUa-0M1W5qFxuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 23, 2017 at 2:21 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> On Fri, Jun 23, 2017 at 12:29 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> The memory allocation size is controlled by user-space,
>> if it is too large just fail silently and return NULL,
>> not to mention there is a fallback allocation later.
>
> Thanks!
>
> Tested-by: Andrey Konovalov <andreyknvl.com>

Should be:
Tested-by: Andrey Konovalov <andreyknvl@google.com>

>
>>
>> Reported-by: Andrey Konovalov <andreyknvl@google.com>
>> Cc: Andrey Konovalov <andreyknvl@google.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>>  net/ipv6/sit.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
>> index 2378503..f8ad158 100644
>> --- a/net/ipv6/sit.c
>> +++ b/net/ipv6/sit.c
>> @@ -305,7 +305,7 @@ static int ipip6_tunnel_get_prl(struct ip_tunnel *t,
>>          * we try harder to allocate.
>>          */
>>         kp = (cmax <= 1 || capable(CAP_NET_ADMIN)) ?
>> -               kcalloc(cmax, sizeof(*kp), GFP_KERNEL) :
>> +               kcalloc(cmax, sizeof(*kp), GFP_KERNEL | __GFP_NOWARN) :
>>                 NULL;
>>
>>         rcu_read_lock();
>> --
>> 2.5.5
>>
