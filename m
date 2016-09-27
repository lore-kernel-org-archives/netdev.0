From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH v4 5/7] ipv6 addrconf: implement RFC7559 router
 solicitation backoff
Date: Tue, 27 Sep 2016 18:42:17 +0900
Message-ID: <CANP3RGfHPZLHFnp4Rq8_dRNCro6Uh8O8767NgoGu7gvzu5h9BQ@mail.gmail.com>
References: <20160925.060423.854801855957024790.davem@davemloft.net>
 <1474801390-6891-1-git-send-email-zenczykowski@gmail.com> <1474801390-6891-6-git-send-email-zenczykowski@gmail.com>
 <f249b2b1-e19f-bbc6-d02e-b256fd369c16@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux NetDev <netdev@vger.kernel.org>,
        Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:36820 "EHLO
        mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752345AbcI0JmT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 05:42:19 -0400
Received: by mail-yw0-f179.google.com with SMTP id t67so4713921ywg.3
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 02:42:19 -0700 (PDT)
In-Reply-To: <f249b2b1-e19f-bbc6-d02e-b256fd369c16@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Please just use do_div here and go back to the first version of the
> patch. Variable names could be more aligned with the RFC maybe?

So I tried:

static inline s32 rfc3315_s14_backoff_init(s32 irt)
 {
       /* multiply 'initial retransmission time' by 0.9 .. 1.1 */
       u64 tmp = (900000 + prandom_u32() % 200001) * (u64)irt;
       do_div(tmp, 1000000);
       return (s32)tmp;
 }

static inline s32 rfc3315_s14_backoff_update(s32 rt, s32 mrt)
 {
       /* multiply 'retransmission timeout' by 1.9 .. 2.1 */
       u64 tmp = (1900000 + prandom_u32() % 200001) * (u64)rt;
       do_div(tmp, 1000000);
       if ((s32)tmp > mrt) {
               /* multiply 'maximum retransmission time' by 0.9 .. 1.1 */
               tmp = (900000 + prandom_u32() % 200001) * (u64)mrt;
               do_div(tmp, 1000000);
        }
       return (s32)tmp;
}

but then building for i386 I get:

ERROR: "__udivdi3" [net/netfilter/xt_hashlimit.ko] undefined!

which happens even at net-next/master itself.

Anyway, I'll resubmit assuming the above is what you're looking for...
