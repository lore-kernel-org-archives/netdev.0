From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH net-next 1/1] net: sock: Use USEC_PER_SEC macro instead of
 literal 1000000
Date: Tue, 21 Feb 2017 15:23:52 +0800
Message-ID: <CA+6hz4rYW+cghnEtObUD=-ZGHE7Lwc1Q+VE23QU4-RKNfY8LZw@mail.gmail.com>
References: <1487601224-22241-1-git-send-email-fgao@ikuai8.com> <1487661214.2853.14.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, soheil@google.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:32886 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750837AbdBUHXx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 02:23:53 -0500
Received: by mail-ua0-f193.google.com with SMTP id d5so10459352uag.0
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 23:23:53 -0800 (PST)
In-Reply-To: <1487661214.2853.14.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 3:13 PM, Joe Perches <joe@perches.com> wrote:
> On Mon, 2017-02-20 at 22:33 +0800, fgao@ikuai8.com wrote:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> The USEC_PER_SEC is used once in sock_set_timeout as the max value of
>> tv_usec. But there are other similar codes which use the literal
>> 1000000 in this file.
>> It is minor cleanup to keep consitent.
> []
>> diff --git a/net/core/sock.c b/net/core/sock.c
> []
>> @@ -367,7 +367,7 @@ static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
>>       if (tv.tv_sec == 0 && tv.tv_usec == 0)
>>               return 0;
>>       if (tv.tv_sec < (MAX_SCHEDULE_TIMEOUT/HZ - 1))
>> -             *timeo_p = tv.tv_sec*HZ + (tv.tv_usec+(1000000/HZ-1))/(1000000/HZ);
>> +             *timeo_p = tv.tv_sec * HZ + (tv.tv_usec + (USEC_PER_SEC / HZ - 1)) / (USEC_PER_SEC / HZ);
>
> Maybe convert this to DIV_ROUND_UP one day too?
>
>         *timeo_p = tv.tv_sec * HZ + DIV_ROUND_UP(tv.tv_usec, USEC_PER_SEC / HZ);
>

Good idea, thanks.
I would send v2 update.

Regards
Feng
