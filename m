From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] netfilter: nf_conntrack: use safer way to lock all
 buckets
Date: Wed, 13 Jan 2016 13:37:33 -0500
Message-ID: <5696996D.20602@oracle.com>
References: <1451960746-28915-1-git-send-email-sasha.levin@oracle.com>
 <20160110010637.GA22861@breakpoint.cc> <20160113165422.GA20585@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, kaber@trash.net,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160113165422.GA20585@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/13/2016 11:54 AM, Pablo Neira Ayuso wrote:
> On Sun, Jan 10, 2016 at 02:06:37AM +0100, Florian Westphal wrote:
>> > Sasha Levin <sasha.levin@oracle.com> wrote:
>>> > > Fix this by using a global lock and synchronize all buckets on it when we
>>> > > need to lock them all. This is pretty heavyweight, but is only done when we
>>> > > need to resize the hashtable, and that doesn't happen often enough (or at all).
>> > 
>>> > > diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
>>> > > index 3cb3cb8..3c008ce 100644
>>> > > --- a/net/netfilter/nf_conntrack_core.c
>>> > > +++ b/net/netfilter/nf_conntrack_core.c
>>> > > @@ -66,6 +66,32 @@ EXPORT_SYMBOL_GPL(nf_conntrack_locks);
>>> > >  __cacheline_aligned_in_smp DEFINE_SPINLOCK(nf_conntrack_expect_lock);
>>> > >  EXPORT_SYMBOL_GPL(nf_conntrack_expect_lock);
>>> > >  
>>> > > +spinlock_t nf_conntrack_locks_all_lock;
>>> > > +bool nf_conntrack_locks_all;
>> > 
>> > Seems both of these can be static and __read_mostly too --
>> > as you already note resizing virtually never happens.
>> >
>> > Otherwise:
>> > Reviewed-by: Florian Westphal <fw@strlen.de>
> Sasha, would you resubmit addressing Florian's feedback?

Yup, sorry - still catching up with the holidays vacation :(


Thanks,
Sasha
