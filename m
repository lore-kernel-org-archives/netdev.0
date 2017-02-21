From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/dccp: fix use after free in tw_timer_handler()
Date: Tue, 21 Feb 2017 13:23:03 -0500 (EST)
Message-ID: <20170221.132303.1154431393145795762.davem@davemloft.net>
References: <20170221112740.661-1-aryabinin@virtuozzo.com>
        <20170221134332.GA5052@kernel.org>
        <CANn89iJwGgyskr99Zp6HD7LPg7YfBtRWe4Br4GzV4g9UfN=sgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@kernel.org, aryabinin@virtuozzo.com, ebiederm@xmission.com,
        gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org, dvyukov@google.com,
        xiyou.wangcong@gmail.com, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        syzkaller@googlegroups.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: edumazet@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iJwGgyskr99Zp6HD7LPg7YfBtRWe4Br4GzV4g9UfN=sgQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 21 Feb 2017 05:53:13 -0800

> On Tue, Feb 21, 2017 at 5:43 AM, Arnaldo Carvalho de Melo
> <acme@kernel.org> wrote:
>>
>> Em Tue, Feb 21, 2017 at 02:27:40PM +0300, Andrey Ryabinin escreveu:
>> > DCCP doesn't purge timewait sockets on network namespace shutdown.
>> > So, after net namespace destroyed we could still have an active timer
>> > which will trigger use after free in tw_timer_handler():
>> >
>> >
>> > Add .exit_batch hook to dccp_v4_ops()/dccp_v6_ops() which will purge
>> > timewait sockets on net namespace destruction and prevent above issue.
>>
>> Please add this, to help stable kernels to pick this up
>>
>> Fixes: b099ce2602d8 ("net: Batch inet_twsk_purge")
>> Cc: Eric W. Biederman <ebiederm@xmission.com>
> 
> 
> This patch has nothing to do with this bug really.
> 
> Look at commit d315492b1a6ba29da0fa2860759505ae1b2db857
> ("netns : fix kernel panic in timewait socket destruction")
> 
> Back in 2008, nobody spotted that DCCP was using the same infra.

So, let me get this straight, dccp is buggy because it tried as hard as
possible to share and use common pieces of infrastructure instead of
duplicating all of said logic?

Now I've heard everything.

I know it has been a pain in the rear fixing all of these dccp bugs,
but removing it from the tree or even pushing it into staging is
simply not an option.  So we better come up with a better plan based
upon reality rather than fantasy. :-)
