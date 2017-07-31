From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] ipv6: set fc_protocol with 0 when rtm_protocol is RTPROT_REDIRECT
Date: Mon, 31 Jul 2017 15:31:32 +1200
Message-ID: <CADvbK_ew8tD=sQQkZ03ijGafFQEzR0sf69DZ1_rNkX9E5mFpuw@mail.gmail.com>
References: <e9342d18b97fc227cacc19db1b43f4c7350eed3f.1501419097.git.lucien.xin@gmail.com>
 <9fcbffcb-4a14-764c-7fe4-2108b8944c17@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
        =?UTF-8?Q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35523 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751700AbdGaDbd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 23:31:33 -0400
Received: by mail-qk0-f196.google.com with SMTP id a77so8153773qkb.2
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 20:31:33 -0700 (PDT)
In-Reply-To: <9fcbffcb-4a14-764c-7fe4-2108b8944c17@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 2:35 PM, David Ahern <dsahern@gmail.com> wrote:
> On 7/30/17 6:51 AM, Xin Long wrote:
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index 4d30c96..187580f 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -2912,9 +2912,11 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
>>       cfg->fc_dst_len = rtm->rtm_dst_len;
>>       cfg->fc_src_len = rtm->rtm_src_len;
>>       cfg->fc_flags = RTF_UP;
>> -     cfg->fc_protocol = rtm->rtm_protocol;
>>       cfg->fc_type = rtm->rtm_type;
>>
>> +     if (rtm->rtm_protocol != RTPROT_REDIRECT)
>> +             cfg->fc_protocol = rtm->rtm_protocol;
>> +
>>       if (rtm->rtm_type == RTN_UNREACHABLE ||
>>           rtm->rtm_type == RTN_BLACKHOLE ||
>>           rtm->rtm_type == RTN_PROHIBIT ||
Hi, David
>
> Did you look at removing this hunk from rt6_fill_node:
>
>         if (rt->rt6i_flags & RTF_DYNAMIC)
>                 rtm->rtm_protocol = RTPROT_REDIRECT;
>         else if (rt->rt6i_flags & RTF_ADDRCONF) {
>                 if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ROUTEINFO))
>                         rtm->rtm_protocol = RTPROT_RA;
>                 else
>                         rtm->rtm_protocol = RTPROT_KERNEL;
>         }
The issue seems to affect "ip -6 route flush all" as well, not only cache
since 'else if {}' also  causes rtm proto being different from rt6 proto.

>
> And have rtm_protocol set properly on the route when it is installed?
The codes not keeping rtm proto consistent with rt6 proto day 1,
any idea on why it didn't use rt6 proto in kernel properly?

Thanks.
