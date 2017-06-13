From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Lockdep splat with tc filter on 4.11
Date: Tue, 13 Jun 2017 10:52:26 -0700
Message-ID: <CAM_iQpWWQjUqL_ZRfSk_Pi1C_dewxvmz2R12_m8egF4th0CBtA@mail.gmail.com>
References: <d1a11d1e-c167-3bab-7b82-10932dedfb1d@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        nicholashuber@gmail.com
To: Laura Abbott <labbott@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d1a11d1e-c167-3bab-7b82-10932dedfb1d@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 13, 2017 at 10:28 AM, Laura Abbott <labbott@redhat.com> wrote:
> Hi,
>
> Fedora got a bug report https://bugzilla.redhat.com/show_bug.cgi?id=1459626
> of a hang on 4.11.3 with lockdep splat:
>
> [  129.100206] BUG: sleeping function called from invalid context at mm/slab.h:432
> [  129.100237] in_atomic(): 1, irqs_disabled(): 0, pid: 1793, name: tc
> [  129.100239] 2 locks held by tc/1793:
> [  129.100241]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8c826217>] rtnl_lock+0x17/0x20
> [  129.100250]  #1:  (&(&p->tcfa_lock)->rlock){+...+.}, at: [<ffffffffc08ba22d>] tcf_act_police_init+0x22d/0x580 [act_police]
> [  129.100259] CPU: 2 PID: 1793 Comm: tc Not tainted 4.11.3-202.fc25.x86_64+debug #1
> [  129.100261] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-1.fc25 04/01/2014
> [  129.100262] Call Trace:
> [  129.100270]  dump_stack+0x86/0xc3
> [  129.100274]  ___might_sleep+0x17d/0x250
> [  129.100277]  __might_sleep+0x4a/0x80
> [  129.100280]  kmem_cache_alloc_trace+0x1e6/0x2d0
> [  129.100284]  ? gen_new_estimator+0x76/0x1d0
> [  129.100288]  gen_new_estimator+0x76/0x1d0
> [  129.100293]  gen_replace_estimator+0xe/0x10
> [  129.100296]  tcf_act_police_init+0x255/0x580 [act_police]


Thanks for the report!

That spinlock is intended to serialize police->tcf_rate_est,
but it looks unnecessary since we already have rtnl lock.

I will work on a patch.
