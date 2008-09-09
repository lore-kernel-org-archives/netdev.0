From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 05/33] netns ct: per-netns expectations
Date: Tue, 9 Sep 2008 11:07:26 +0400
Message-ID: <20080909070726.GD5786@x200.localdomain>
References: <48C01046.2070704@trash.net> <1220842990-30500-5-git-send-email-adobriyan@gmail.com> <48C60E6E.5080905@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48C60E6E.5080905@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 09, 2008 at 07:49:34AM +0200, Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>> Make per-netns a) expectation hash and b) expectations count.
>>
>> Expectations always belongs to netns to which it's master conntrack belong.
>> This is natural and doesn't bloat expectation.
>>
>> Proc files and leaf users are stubbed to init_net, this is temporary.
>
> Looks fine, applied.
>
>> @@ -406,7 +404,7 @@ int nf_ct_expect_related(struct nf_conntrack_expect *expect)
>>  		}
>>  	}
>>  -	if (nf_ct_expect_count >= nf_ct_expect_max) {
>> +	if (net->ct.expect_count >= nf_ct_expect_max) {
>>  		if (net_ratelimit())
>>  			printk(KERN_WARNING
>>  			       "nf_conntrack: expectation table full\n");
>
> I assume these message are globally visible even with namespaces?
> Can we make this (and the corresponding ct hash message) refer to
> the namespace? Otherwise it might be a bit confusing.

This is somewhat peculiar situation.

netns doesn't have unique ID like, say, ifindex.

The only number related to netns is "struct net *". They can be
distinguised by pointer value, but userspace when does clone(CLONE_NEWNET)
do not, obviously, control it and after creation doesn't have a way to find
it out.

And if we print with "%p, net" kernelspace pointer get exposed which is
not nice.
