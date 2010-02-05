From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH for 2.6.33] conntrack: restrict runtime hashsize modifications
Date: Fri, 05 Feb 2010 11:21:05 +0100
Message-ID: <4B6BF111.60205@trash.net>
References: <20100203203929.GA6168@x200> <4B6AF36A.3050402@trash.net>	 <4B6AFE22.20304@trash.net> <1265314835.2861.524.camel@tonnant>	 <4B6BECF8.1010508@trash.net> <1265364761.2861.757.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>, davem@davemloft.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33191 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511Ab0BEKVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 05:21:09 -0500
In-Reply-To: <1265364761.2861.757.camel@tonnant>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jon Masters wrote:
> On Fri, 2010-02-05 at 11:03 +0100, Patrick McHardy wrote:
>> Jon Masters wrote:
>>> On Thu, 2010-02-04 at 18:04 +0100, Patrick McHardy wrote:
>>>>> How about alternatively moving nf_conntrack_hsize into the
>>>>> per-namespace struct? It doesn't look more complicated or
>>>>> intrusive and would allow to still change the init_net
>>>>> hashsize. Also seems less hackish :)
>>>> How about this (so far untested) patch? The htable_size is moved into
>>>> the per-namespace struct and initialized from the current (global)
>>>> value of nf_conntrack_htable_size. Changes through sysfs are still
>>>> permitted, but only affect the init namespace and newly created ones.
>>> I moved the random seed into the per-ns context aswell. I think that's
>>> better than having a global one, and you don't need to rehash all.
>> That's another possibility. But we don't loose anything by not
>> reseeding during resize. It also shouldn't be possible to determine
>> the seed from userspace in a namespace, so there's no real need
>> to use seperate values.
> 
> Right, the risk there is hypothetical at best. But there's little lost
> in putting it in per-ns and then you can rehash and truly make them
> independent, which I think is really what netns is all about.

I don't disagree, but currently I'm trying to go for a minimal
version thats suitable for 2.6.33.
