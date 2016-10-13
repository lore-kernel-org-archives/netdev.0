From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: slab corruption with current -git
Date: Thu, 13 Oct 2016 08:02:06 +0200
Message-ID: <20161013060206.GA310@x4>
References: <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
 <CA+55aFzcweyWCqq-fRAnJkFB7neKwKsXH=TMcLtRQRs2Wn6XEQ@mail.gmail.com>
 <CA+55aFwhscZcWJVLbq+qUgNaN34VwBxFwUR97ktM-7003PcexQ@mail.gmail.com>
 <20161011.045737.227906000874505402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, aconole@redhat.com, fw@strlen.de,
        viro@zeniv.linux.org.uk, akpm@linux-foundation.org, axboe@fb.com,
        tytso@mit.edu, cl@linux.com, pablo@netfilter.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161011.045737.227906000874505402.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016.10.11 at 04:57 -0400, David Miller wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Mon, 10 Oct 2016 22:47:50 -0700
> 
> > On Mon, Oct 10, 2016 at 10:39 PM, Linus Torvalds
> > <torvalds@linux-foundation.org> wrote:
> >>
> >> I guess I will have to double-check that the slub corruption is gone
> >> still with that fixed.
> > 
> > So I'm not getting any warnings now from SLUB debugging. So the
> > original bug seems to not have re-surfaced, and the registration bug
> > is gone, so now the unregistration doesn't warn about anything either.
> > 
> > But I only rebooted three times.
> 
> Looks good to me, I applied it to my tree with your signoff and will
> send you a pull request right now.

I'm still seeing:

nf_conntrack version 0.5.0 (4096 buckets, 16384 max)
ctnetlink v0.93: registering with nfnetlink.
ip_tables: (C) 2000-2006 Netfilter Core Team
WARNING: kmemcheck: Caught 64-bit read from uninitialized memory (ffff88001e605480)
4055601e0088ffff000000000000000090686d81ffffffff0000000000000000
 u u u u u u u u u u u u u u u u i i i i i i i i u u u u u u u u
 ^
RIP: 0010:[<ffffffff8166e561>]  [<ffffffff8166e561>] nf_register_net_hook+0x51/0x160
RSP: 0018:ffffc9000000bcc0  EFLAGS: 00010286
RAX: ffff88001e5af9c0 RBX: ffff88001e605480 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff88001e5b0a20
RBP: ffffc9000000bcd8 R08: 000000001fd0e000 R09: 0000000000000000
R10: ffff88001e5b09c0 R11: 0000000000000067 R12: ffff88001e5af9c0
R13: ffffffff81c5c0c8 R14: 0000000000000003 R15: ffff88001e605480
FS:  0000000000000000(0000) GS:ffff88001fa00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffff88001f45ca18 CR3: 0000000001c07000 CR4: 00000000000006f0
 [<ffffffff8166e561>] nf_register_net_hook+0x51/0x160
 [<ffffffff8166eaaf>] nf_register_net_hooks+0x3f/0xa0
 [<ffffffff816d6715>] ipt_register_table+0xe5/0x110
 [<ffffffff816d6815>] iptable_filter_table_init.part.1+0x55/0x80
 [<ffffffff816d688b>] iptable_filter_net_init+0x2b/0x30
 [<ffffffff8163edd7>] ops_init+0x47/0x150
 [<ffffffff8163f0c6>] register_pernet_operations+0xd6/0x170
 [<ffffffff8163fb77>] register_pernet_subsys+0x27/0x40
 [<ffffffff81cb9de3>] iptable_filter_init+0x33/0x4b
 [<ffffffff81c8bef0>] do_one_initcall+0x8b/0x113
 [<ffffffff81c8c091>] kernel_init_freeable+0x119/0x1a1
 [<ffffffff816efd09>] kernel_init+0x9/0x100
 [<ffffffff816f4e12>] ret_from_fork+0x22/0x30
 [<ffffffffffffffff>] 0xffffffffffffffff
NET: Registered protocol family 17
9pnet: Installing 9P2000 support


-- 
Markus
