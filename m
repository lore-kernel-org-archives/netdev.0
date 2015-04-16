From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when refragmenting
Date: Thu, 16 Apr 2015 22:32:11 +0200
Message-ID: <CBDCE1F1-CA43-4973-A195-357B0DFDE5BC@trash.net>
References: <20150416052357.GA3285@acer.localdomain> <20150416052904.GA12648@gondor.apana.org.au> <1429186302.1075929.254563877.238D8F77@webmail.messagingengine.com> <20150416.114323.2122666447487730641.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: herbert@gondor.apana.org.au, fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38851 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503AbbDPUcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 16:32:15 -0400
In-Reply-To: <20150416.114323.2122666447487730641.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 16. April 2015 17:43:23 MESZ, schrieb David Miller <davem@davemloft.net>:
>From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>Date: Thu, 16 Apr 2015 14:11:42 +0200
>
>> On Thu, Apr 16, 2015, at 07:29, Herbert Xu wrote:
>>> On Thu, Apr 16, 2015 at 06:24:00AM +0100, Patrick McHardy wrote:
>>> >
>>> > Netfilter may change the contents of the packet, even change its
>size.
>>> > It is *really* hard to do this while keeping the original
>fragments
>>> > intact.
>>> 
>>> Perhaps we should provide better helpers to facilitate this?
>>> 
>>> So instead of directly manipulating the content of the skb you
>>> would so so through helpers and the helpers can then try to do
>>> sensible things with the fragments.
>> 
>> When Florian and me started discussing how to solve this we also
>wanted
>> to be as transparent as possible. But looking at all possible
>> fragmentation scenarios, this seems to be too complicated.
>> 
>> Even imagine a fragment with overlapping offsets and some of the
>> fragments got duplicated. If we had to keep this in frag_list and now
>> netfilter has to change any of this contents, this will become a
>total
>> mess, like changing one port in multiple skbs at different offsets.
>> 
>> I doubt it is worth the effort.
>
>You guys keep talking about exceptional cases rather than what is
>unquestionable the common case, and the one worth handling in the
>fast paths.

True. But its not like we haven't tried. What I keep hearing is lots of well meaning opinions, and the fact is, I've looked into this countless times, you can find my first attempt when googling from 11 years ago, and the resolution was always - it's not worth it. It's not "too hard", I wouldn't mind. And I fail to see the problem with that. We're not talking about a functional defect, it's something people (me included) think is "not nice".

I will try to recollect the problems the different approaches have in detail. I'm pretty sure you will come to the same conclusion as I have.
