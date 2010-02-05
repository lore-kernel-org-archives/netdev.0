From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH for 2.6.33] conntrack: restrict runtime hashsize modifications
Date: Fri, 05 Feb 2010 12:16:57 +0100
Message-ID: <4B6BFE29.1040204@trash.net>
References: <20100203203929.GA6168@x200> <4B6AF36A.3050402@trash.net> <4B6AFE22.20304@trash.net> <20100204194744.GA4185@x200> <4B6BEC23.8020101@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jonathan@jonmasters.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B6BEC23.8020101@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>>> How about this (so far untested) patch? The htable_size is moved into
>>> the per-namespace struct and initialized from the current (global)
>>> value of nf_conntrack_htable_size. Changes through sysfs are still
>>> permitted, but only affect the init namespace and newly created ones.
>> No matter what we do, it's a hack!
>>
>>> Additionally I removed reinitializing the hash random value when
>>> changing the hash size since that also requires to rehash in all
>>> namespaces.
>> I'm not fond of this, because we're not even closely going to allow changing
>> hashtable size per-netns. As such having actual per-netns hashtable size
>> just slows down everything.
> 
> Actually it doesn't seem like much more work to allow changing
> table size, the main problem is that sysfs module parameters
> don't seem to fit into the network namespace model at all.
> 
> Please be more specific about your suspected slowdowns.
> What's "everything"? What's different about the hashsize
> compared to the many members we already moved to per-netns
> structs?

OK testing looks fine, although I'm quite surprised that its actually
possible to change module parameters from within non-init namespaces.
How is this supposed to work at all? I don't see how sysfs could
possibly provide a network namespace context ...
