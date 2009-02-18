From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFT 4/4] netfilter: Get rid of central rwlock in tcp conntracking
Date: Thu, 19 Feb 2009 00:23:45 +0100
Message-ID: <499C9881.2080909@trash.net>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.679540125@vyatta.com>	<499BDB5D.2050105@trash.net> <20090218.135512.104648058.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, rick.jones2@hp.com, dada1@cosmosbay.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090218.135512.104648058.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 18 Feb 2009 10:56:45 +0100
> 
>> Eric already posted a patch to use an array of locks, which is
>> a better approach IMO since it keeps the size of the conntrack
>> entries down.
> 
> Just as a side note, we generally frown upon the
> hash-array-of-spinlocks approach to scalability.
> 
> If you need proof that in the long term it's suboptimal, note that:
> 
> 1) this is Solaris's approach to locking scalability :-)

:)

> 2) every such case in the kernel eventually gets transformed into
>    RCU, a tree/trie based scheme, or some combination of the two
> 
> So maybe for now it's ok, but keep in mind that eventually
> this is certain to change. :)

This case might be different in that a normal firewall use case
probably doesn't have more than 16 cpus, even than would be quite
a lot. So for bigger machines this is probably more about keeping
the "non-use" costs low.

I'll keep it in mind though and I'm interested in seeing how it
turns out in the long term :)
