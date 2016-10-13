From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: slab corruption with current -git
Date: Thu, 13 Oct 2016 08:06:59 +0200
Message-ID: <20161013060659.GB310@x4>
References: <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
 <CA+55aFzcweyWCqq-fRAnJkFB7neKwKsXH=TMcLtRQRs2Wn6XEQ@mail.gmail.com>
 <CA+55aFwhscZcWJVLbq+qUgNaN34VwBxFwUR97ktM-7003PcexQ@mail.gmail.com>
 <20161011.045737.227906000874505402.davem@davemloft.net>
 <20161013060206.GA310@x4>
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
In-Reply-To: <20161013060206.GA310@x4>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016.10.13 at 08:02 +0200, Markus Trippelsdorf wrote:
> On 2016.10.11 at 04:57 -0400, David Miller wrote:
> > From: Linus Torvalds <torvalds@linux-foundation.org>
> > Date: Mon, 10 Oct 2016 22:47:50 -0700
> > 
> > > On Mon, Oct 10, 2016 at 10:39 PM, Linus Torvalds
> > > <torvalds@linux-foundation.org> wrote:
> > >>
> > >> I guess I will have to double-check that the slub corruption is gone
> > >> still with that fixed.
> > > 
> > > So I'm not getting any warnings now from SLUB debugging. So the
> > > original bug seems to not have re-surfaced, and the registration bug
> > > is gone, so now the unregistration doesn't warn about anything either.
> > > 
> > > But I only rebooted three times.
> > 
> > Looks good to me, I applied it to my tree with your signoff and will
> > send you a pull request right now.
> 
> I'm still seeing:
> 
> nf_conntrack version 0.5.0 (4096 buckets, 16384 max)
> ctnetlink v0.93: registering with nfnetlink.
> ip_tables: (C) 2000-2006 Netfilter Core Team
> WARNING: kmemcheck: Caught 64-bit read from uninitialized memory (ffff88001e605480)
> 4055601e0088ffff000000000000000090686d81ffffffff0000000000000000
>  u u u u u u u u u u u u u u u u i i i i i i i i u u u u u u u u
>  ^
> RIP: 0010:[<ffffffff8166e561>]  [<ffffffff8166e561>] nf_register_net_hook+0x51/0x160

This is nf_register_net_hook at net/netfilter/core.c:106

-- 
Markus
