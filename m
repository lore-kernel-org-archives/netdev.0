From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH for 2.6.33] conntrack: restrict runtime hashsize modifications
Date: Fri, 05 Feb 2010 11:19:08 +0100
Message-ID: <4B6BF09C.9090603@trash.net>
References: <20100203203929.GA6168@x200> <4B6AF36A.3050402@trash.net>	 <4B6AFE22.20304@trash.net> <20100204194744.GA4185@x200>	 <4B6BEC23.8020101@trash.net> <1265364693.2861.756.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>, davem@davemloft.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1265364693.2861.756.camel@tonnant>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jon Masters wrote:
> On Fri, 2010-02-05 at 11:00 +0100, Patrick McHardy wrote:
>>>> How about this (so far untested) patch? The htable_size is moved into
>>>> the per-namespace struct and initialized from the current (global)
>>>> value of nf_conntrack_htable_size. Changes through sysfs are still
>>>> permitted, but only affect the init namespace and newly created ones.
>>> No matter what we do, it's a hack!
>>>
>>>> Additionally I removed reinitializing the hash random value when
>>>> changing the hash size since that also requires to rehash in all
>>>> namespaces.
>>> I'm not fond of this, because we're not even closely going to allow changing
>>> hashtable size per-netns. As such having actual per-netns hashtable size
>>> just slows down everything.
>> Actually it doesn't seem like much more work to allow changing
>> table size, the main problem is that sysfs module parameters
>> don't seem to fit into the network namespace model at all.
> 
> That was the reason I initially suggested we need a better way to expose
> netns topology through sysfs, which I still think is a good idea. How
> about this...it's dangerous as it is right now to leave things global. I
> suggest leaving the existing sysfs module parameter that only actually
> touches the init_net ct and get the rest fixed up, then adding support
> for exposing the topology better in sysfs and tweaking per-ns bits.
> 
> But maybe you want to fix it all at the same time.

No, right now I only want to fix the remaining bugs. I'll leave
everything else to the netns people.
