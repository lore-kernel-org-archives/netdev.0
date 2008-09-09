From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 16/33] netns ct: per-netns event cache
Date: Tue, 9 Sep 2008 11:07:42 +0400
Message-ID: <20080909070742.GE5786@x200.localdomain>
References: <48C01046.2070704@trash.net> <1220842990-30500-16-git-send-email-adobriyan@gmail.com> <48C613CB.5000303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48C613CB.5000303@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 09, 2008 at 08:12:27AM +0200, Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>> Heh, last minute proof-reading of this patch made me think,
>> that this is actually unneeded, simply because "ct" pointers will be
>> different for different conntracks in different netns, just like they
>> are different in one netns.
>>
>> Not so sure anymore.
>
> Its necessary because the cache needs to be flushed on netns exit
> and this is only allowed while its not in use anymore.
>
> I don't see anything in this series actually making sure nothing
> hits the cache on exit though. Am I missing something?

When netns refcount hits zero, netdevices in it will start dropping packets.
And there is synchronize_net() call before cache flush.

I think this is enough.

> Additionally (I might have missed a following patch moving it
> out though) this doesn't belong in the netns exit path:
>
> void nf_conntrack_cleanup(struct net *net)
> {
> 	rcu_assign_pointer(ip_ct_attach, NULL);
> ...
> 	rcu_assign_pointer(nf_ct_destroy, NULL);

This is dealt with in 17/33

Have you got 18/33, archives show it's missing?
