From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: suspicious RCU usage in nf_hook
Date: Thu, 2 Feb 2017 10:01:02 -0800
Message-ID: <CAM_iQpUVma3R7wGJ8T8FWyCpU9joiGM+8LSPMcV2xpJLiRD-pw@mail.gmail.com>
References: <CACT4Y+bpmwj1WH7g6inQBm+7PvHepv9tTmYBUqkJYFvquGDYCQ@mail.gmail.com>
 <1485560124.6360.74.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVvBPhP4q=Egsaoqf8ym-73jLZow8xDMbOq9RhYmL5XAQ@mail.gmail.com>
 <1485567090.6360.92.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXiQMH1zMJM6sYFNUySUYjaHnLZ3T2d34GwCMQ9u6RkwQ@mail.gmail.com>
 <1485877498.6360.115.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpWnJbN=65D8PAxe7B_kBf7+Ay2M59T8brF0aXkfEbgnPg@mail.gmail.com>
 <1485983770.6360.158.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpWSpgNnEOn+euZAMEmdQCfDVcgk9EO=k5-kVEkB+EJrpg@mail.gmail.com>
 <CANn89iJb55jCppc9J=vL9n=7ofr1LSz3d+nKNo4W-BJeoH0m3A@mail.gmail.com> <1485993583.6360.172.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485993583.6360.172.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 1, 2017 at 3:59 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2017-02-01 at 15:48 -0800, Eric Dumazet wrote:
>> On Wed, Feb 1, 2017 at 3:29 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>
>> > Not sure if it is better. The difference is caught up in net_enable_timestamp(),
>> > which is called setsockopt() path and sk_clone() path, so we could be
>> > in netstamp_needed state for a long time too until user-space exercises
>> > these paths.
>> >
>> > I am feeling we probably need to get rid of netstamp_needed_deferred,
>> > and simply defer the whole static_key_slow_dec(), like the attached patch
>> > (compile only).
>> >
>> > What do you think?
>>
>> I think we need to keep the atomic.
>>
>> If two cpus call net_disable_timestamp() roughly at the same time, the
>> work will be scheduled once.

Good point! Yeah, the same work will not be schedule twice.

>
> Updated patch (but not tested yet)

I can't think out a better way to fix this. I expect jump_label to provide
an API for this, but it doesn't, static_key_slow_dec_deferred()
is just for batching. Probably we should introduce one to avoid these
ugly #ifdef HAVE_JUMP_LABEL here, but that is a -next material.

So, please feel free to send it formally.

Thanks.
