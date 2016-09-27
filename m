From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4 5/7] ipv6 addrconf: implement RFC7559 router
 solicitation backoff
Date: Tue, 27 Sep 2016 12:20:49 +0200
Message-ID: <cea2e6f6-98f3-50b4-a68e-7af6d9903d91@stressinduktion.org>
References: <20160925.060423.854801855957024790.davem@davemloft.net>
 <1474801390-6891-1-git-send-email-zenczykowski@gmail.com>
 <1474801390-6891-6-git-send-email-zenczykowski@gmail.com>
 <f249b2b1-e19f-bbc6-d02e-b256fd369c16@stressinduktion.org>
 <CANP3RGfHPZLHFnp4Rq8_dRNCro6Uh8O8767NgoGu7gvzu5h9BQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux NetDev <netdev@vger.kernel.org>,
        Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>, vpai@akamai.com
To: =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:57961 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751469AbcI0KUw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 06:20:52 -0400
In-Reply-To: <CANP3RGfHPZLHFnp4Rq8_dRNCro6Uh8O8767NgoGu7gvzu5h9BQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[cc Vishwanath Pai]

On 27.09.2016 11:42, Maciej Żenczykowski wrote:
>> Please just use do_div here and go back to the first version of the
>> patch. Variable names could be more aligned with the RFC maybe?
> 
> So I tried:
> 
> static inline s32 rfc3315_s14_backoff_init(s32 irt)
>  {
>        /* multiply 'initial retransmission time' by 0.9 .. 1.1 */
>        u64 tmp = (900000 + prandom_u32() % 200001) * (u64)irt;
>        do_div(tmp, 1000000);
>        return (s32)tmp;
>  }
> 
> static inline s32 rfc3315_s14_backoff_update(s32 rt, s32 mrt)
>  {
>        /* multiply 'retransmission timeout' by 1.9 .. 2.1 */
>        u64 tmp = (1900000 + prandom_u32() % 200001) * (u64)rt;
>        do_div(tmp, 1000000);
>        if ((s32)tmp > mrt) {
>                /* multiply 'maximum retransmission time' by 0.9 .. 1.1 */
>                tmp = (900000 + prandom_u32() % 200001) * (u64)mrt;
>                do_div(tmp, 1000000);
>         }
>        return (s32)tmp;
> }
> 
> but then building for i386 I get:
> 
> ERROR: "__udivdi3" [net/netfilter/xt_hashlimit.ko] undefined!

Hmm, evidently we have some u64 divisions in xt_hashlimit.c which should
be replaced by do_div?
