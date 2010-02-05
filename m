From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH for 2.6.33] conntrack: restrict runtime hashsize modifications
Date: Fri, 05 Feb 2010 11:00:36 +0100
Message-ID: <4B6BEC44.5000101@trash.net>
References: <20100203203929.GA6168@x200> <4B6AF36A.3050402@trash.net>	 <4B6AF58A.202@trash.net> <1265314734.2861.521.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>, davem@davemloft.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1265314734.2861.521.camel@tonnant>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jon Masters wrote:
> On Thu, 2010-02-04 at 17:27 +0100, Patrick McHardy wrote:
>> Patrick McHardy wrote:
>>> Alexey Dobriyan wrote:
>>>> Jon Masters correctly points out that conntrack hash sizes
>>>> (nf_conntrack_htable_size) are global (not per-netns) and
>>>> modifiable at runtime via /sys/module/nf_conntrack/hashsize .
>>>>
>>>> Steps to reproduce:
>>>> 	clone(CLONE_NEWNET)
>>>> 	[grow /sys/module/nf_conntrack/hashsize]
>>>> 	exit()
>>>>
>>>> At netns exit we are going to scan random memory for conntracks to be killed.
>>>>
>>>> Apparently there is a code which deals with hashtable resize for
>>>> init_net (and it was there befode netns conntrack code), so prohibit
>>>> hashsize modification if there is more than one netns exists.
>>>>
>>>> To change hashtable sizes, you need to reload module.
>>>>
>>>> Expectation hashtable size was simply glued to a variable with no code
>>>> to rehash expectations, so it was a bug to allow writing to it.
>>>> Make "expect_hashsize" readonly.
>>>>
>>>> This is temporarily until we figure out what to do.
>>> How about alternatively moving nf_conntrack_hsize into the
>>> per-namespace struct? It doesn't look more complicated or
>>> intrusive and would allow to still change the init_net
>>> hashsize. Also seems less hackish :)
>> Just to avoid duplicate work, I'm currently trying that.
> 
> Bah. I already worked a set of patches to do that as I mentioned, but
> you've probably done it by now - can clean up and post if not :)

Sorry, I missed that in your mail. I'm pretty much done, will finish
testing shortly.
