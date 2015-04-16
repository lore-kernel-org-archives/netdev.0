From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when
 refragmenting
Date: Thu, 16 Apr 2015 11:43:23 -0400 (EDT)
Message-ID: <20150416.114323.2122666447487730641.davem@davemloft.net>
References: <20150416052357.GA3285@acer.localdomain>
	<20150416052904.GA12648@gondor.apana.org.au>
	<1429186302.1075929.254563877.238D8F77@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kaber@trash.net, fw@strlen.de,
	netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbbDPPnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 11:43:24 -0400
In-Reply-To: <1429186302.1075929.254563877.238D8F77@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 16 Apr 2015 14:11:42 +0200

> On Thu, Apr 16, 2015, at 07:29, Herbert Xu wrote:
>> On Thu, Apr 16, 2015 at 06:24:00AM +0100, Patrick McHardy wrote:
>> >
>> > Netfilter may change the contents of the packet, even change its size.
>> > It is *really* hard to do this while keeping the original fragments
>> > intact.
>> 
>> Perhaps we should provide better helpers to facilitate this?
>> 
>> So instead of directly manipulating the content of the skb you
>> would so so through helpers and the helpers can then try to do
>> sensible things with the fragments.
> 
> When Florian and me started discussing how to solve this we also wanted
> to be as transparent as possible. But looking at all possible
> fragmentation scenarios, this seems to be too complicated.
> 
> Even imagine a fragment with overlapping offsets and some of the
> fragments got duplicated. If we had to keep this in frag_list and now
> netfilter has to change any of this contents, this will become a total
> mess, like changing one port in multiple skbs at different offsets.
> 
> I doubt it is worth the effort.

You guys keep talking about exceptional cases rather than what is
unquestionable the common case, and the one worth handling in the
fast paths.
