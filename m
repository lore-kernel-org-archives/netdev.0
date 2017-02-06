From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: deadlock on genl_mutex
Date: Sun, 5 Feb 2017 22:32:24 -0800
Message-ID: <CAM_iQpWjt=mt2+ukaO_TxGZFzTEo8CCAXHXdO2ag+vm_=qr0eQ@mail.gmail.com>
References: <CACT4Y+ZdSNVhF2MH0=t=kBUrgNSSnCSO5uwnnc5c0KNLG+VNFQ@mail.gmail.com>
 <CANn89iJ1G4e655RnfcGK9RwmSSb2L=ZBSq9e2gpHVNmkUOYUxg@mail.gmail.com>
 <0227d7e83cc5ac0a192d1ba0fee61413@codeaurora.org> <CACT4Y+auHN0Rdu2Hepk6DNFmz1K2XSA6s18PC=KZiHdoMG845Q@mail.gmail.com>
 <CACT4Y+Zy82UAJ55VbPbVadUM92ZSx1VJCFPdhhcmj53uxZ5PXQ@mail.gmail.com>
 <CAM_iQpXxF_N+3VYRqjd4jySBbySPsZAAVVkNCBEXqc8gHJ6ZMQ@mail.gmail.com>
 <CAM_iQpW2x5xeBpxnZx+k+vnKkjxWPycCBpiKZE41Kcp5gBsN4w@mail.gmail.com> <CACT4Y+bUNeDM5SeZa0cQSuSJ0rq3i0Y063wK9cUvG9oxuQP7YQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Matti Vaittinen <matti.vaittinen@nokia.com>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        Florian Westphal <fw@strlen.de>,
        stephen hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Richard Guy Briggs <rgb@redhat.com>,
        netdev-owner@vger.kernel.org
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+bUNeDM5SeZa0cQSuSJ0rq3i0Y063wK9cUvG9oxuQP7YQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 29, 2017 at 2:11 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Fri, Dec 9, 2016 at 6:08 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>> Chain exists of:
>>>>  Possible unsafe locking scenario:
>>>>
>>>>        CPU0                    CPU1
>>>>        ----                    ----
>>>>   lock(genl_mutex);
>>>>                                lock(nlk->cb_mutex);
>>>>                                lock(genl_mutex);
>>>>   lock(rtnl_mutex);
>>>>
>>>>  *** DEADLOCK ***
>>>
>>> This one looks legitimate, because nlk->cb_mutex could be rtnl_mutex.
>>> Let me think about it.
>>
>> Never mind. Actually both reports in this thread are legitimate.
>>
>> I know what happened now, the lock chain is so long, 4 locks are involved
>> to form a chain!!!
>>
>> Let me think about how to break the chain.
>
>
> Cong, any success with breaking the chain?

No luck yet. Each part of the chain seems legit, not sure which
one could be reordered. :-/
