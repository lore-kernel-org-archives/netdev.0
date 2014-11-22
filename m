From: Pranith Kumar <bobby.prani@gmail.com>
Subject: Re: [PATCH v2 9/9] netfilter: Replace smp_read_barrier_depends() with lockless_dereference()
Date: Fri, 21 Nov 2014 20:23:11 -0500
Message-ID: <CAJhHMCB4NfOGBKutkM0L42Vp5ASOLupMRMR07H4sUYy_Dc31KQ@mail.gmail.com>
References: <1416582363-20661-1-git-send-email-bobby.prani@gmail.com>
 <1416582363-20661-10-git-send-email-bobby.prani@gmail.com>
 <1416586364.8629.104.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAJhHMCCCSU7PbWdgPouefbLJBcoxR8nmsS8dg_=BcuqVJZbDew@mail.gmail.com> <1416614703.20938.0.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	"open list:NETWORKING [IPv4/..." <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1416614703.20938.0.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 21, 2014 at 7:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> On Fri, 2014-11-21 at 16:57 -0500, Pranith Kumar wrote:
>
>> Hi Eric,
>>
>> Thanks for looking at this patch.
>>
>> I've been scratching my head since morning trying to find out what was
>> so obviously wrong with this patch. Alas, I don't see what you do.
>>
>> Could you point it out and show me how incompetent I am, please?
>>
>> Thanks!
>
> Well, even it the code is _not_ broken, I don't see any value with this
> patch.

Phew. Not being broken itself is a win :)

>
> If I use git blame on current code, line containing
> smp_read_barrier_depends() exactly points to the relevant commit [1]

And that is an opinion I will respect. I don't want to muck the git
history where it is significant.

This effort is to eventually replace the uses of
smp_read_barrier_depends() and to use either rcu or
lockless_dereference() as documented in memory-barriers.txt.

>
> After your change, it will point to some cleanup, which makes little
> sense to me, considering you did not change the smp_wmb() in
> xt_replace_table().

That does not need to change as it is fine as it is. It still pairs
with the smp_read_barrier_depends() in lockless_dereference().

>
> I, as a netfilter contributor would like to keep current code as is,
> because it is how I feel safe with it.
>
> We have a proliferation of interfaces, but this does not help to
> understand the issues and code maintenance.
>
> smp_read_barrier_depends() better documents the read barrier than
> lockless_dereference().

I think this is a matter of opinion. But in the current effort I've
seen cases where it is not clear what the barrier is actually
guaranteeing. I am glad that the current code is not one of those and
it has reasonable comments.

lockless_dereference() on the other hand makes the dependency explicit.

>
> The point of having a lock or not is irrelevant here.
>
> [1]
> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=b416c144f46af1a30ddfa4e4319a8f077381ad63
>
>
>
>


Thanks!
-- 
Pranith
