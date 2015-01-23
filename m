From: Bryton Lee <brytonlee01@gmail.com>
Subject: Re: [PATCH iproute2] update obsolete fields in slabstat_ids[]
Date: Fri, 23 Jan 2015 09:50:17 +0800
Message-ID: <CAC2pzGc+0qEOUX1WSyapHN_Xnw3+2QtCn6uw8m+JMMVT6fDWGA@mail.gmail.com>
References: <CAC2pzGdtPNiEK2g5-87kmzoU6s3umLujuv0fGoEyRfJYst91XA@mail.gmail.com>
	<CAC2pzGe3Yd6sjeQG4UYcf9jyK4txjVR-CADzHEtkevMhWDTCOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Bryton Lee <brytonlee01@gmail.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f177.google.com ([209.85.220.177]:59165 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235AbbAWBuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 20:50:18 -0500
Received: by mail-vc0-f177.google.com with SMTP id hy4so1701590vcb.8
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 17:50:17 -0800 (PST)
In-Reply-To: <CAC2pzGe3Yd6sjeQG4UYcf9jyK4txjVR-CADzHEtkevMhWDTCOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any one has any comment?  Have you didn't saw this issue before when run ss -s ?

On Fri, Jan 16, 2015 at 10:27 AM, Bryton Lee <brytonlee01@gmail.com> wrote:
> Hi Stephen:
>
> This is the first time I submit a patch to iproute2, I forgot CC to a
> iproute2's maintainer. It's my fault. Could you please review my
> patch? :)
>
> this patch can help some old system get TCP info correctly.  such as
> Red Hat 5u7,  although  is not perfect.  ss searching  tcp_bind_bucket
> and request_sock_TCP in /proc/slabinfo will fail on current upstream
> kernel,
> because on current upstream kernel slab tcp_bind_bucket and
> request_sock_TCP have merged into kmalloc-xx when they are creating.
> so  in /proc/slabinfo  we cannot see them any more.
>
> I have submitted other patch to mm subsystem to prevent such merging,
> but it still not accepted. (Yep, finally, I know my patch has problem,
> it doesn't make any sense, but may be we should still think about how
> to prevent slab merging in slab layer. )
>
>
> On Mon, Dec 29, 2014 at 8:16 PM, Bryton Lee <brytonlee01@gmail.com> wrote:
>> From: Bryton Lee <brytonlee01@gmail.com>
>> Date: Mon, 29 Dec 2014 19:56:23 +0800
>> Subject: [PATCH] tcp_open_request and tcp_tw_bucket are obsolete in current
>>  stable kernel version, replace by request_sock_TCP and tw_sock_TCP
>>
>> Signed-off-by: Bryton Lee <brytonlee01@gmail.com>
>> ---
>>  misc/ss.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/misc/ss.c b/misc/ss.c
>> index f0c7b34..24d58c7 100644
>> --- a/misc/ss.c
>> +++ b/misc/ss.c
>> @@ -506,8 +506,8 @@ static const char *slabstat_ids[] =
>>  {
>>      "sock",
>>      "tcp_bind_bucket",
>> -    "tcp_tw_bucket",
>> -    "tcp_open_request",
>> +    "tw_sock_TCP",
>> +    "request_sock_TCP",
>>      "skbuff_head_cache",
>>  };
>>
>> --
>> 2.0.5
>>
>> --
>> Best Regards
>>
>> Bryton.Lee
>>
>
>
>
> --
> Best Regards
>
> Bryton.Lee



-- 
Best Regards

Bryton.Lee
