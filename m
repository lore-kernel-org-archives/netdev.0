From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when
 refragmenting
Date: Thu, 16 Apr 2015 14:11:42 +0200
Message-ID: <1429186302.1075929.254563877.238D8F77@webmail.messagingengine.com>
References: <20150413.135348.461869719021663434.davem@davemloft.net>
 <20150416045622.GA12454@gondor.apana.org.au>
 <20150416052357.GA3285@acer.localdomain>
 <20150416052904.GA12648@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:40596 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754513AbbDPMLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 08:11:42 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 549D720FB4
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 08:11:42 -0400 (EDT)
In-Reply-To: <20150416052904.GA12648@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2015, at 07:29, Herbert Xu wrote:
> On Thu, Apr 16, 2015 at 06:24:00AM +0100, Patrick McHardy wrote:
> >
> > Netfilter may change the contents of the packet, even change its size.
> > It is *really* hard to do this while keeping the original fragments
> > intact.
> 
> Perhaps we should provide better helpers to facilitate this?
> 
> So instead of directly manipulating the content of the skb you
> would so so through helpers and the helpers can then try to do
> sensible things with the fragments.

When Florian and me started discussing how to solve this we also wanted
to be as transparent as possible. But looking at all possible
fragmentation scenarios, this seems to be too complicated.

Even imagine a fragment with overlapping offsets and some of the
fragments got duplicated. If we had to keep this in frag_list and now
netfilter has to change any of this contents, this will become a total
mess, like changing one port in multiple skbs at different offsets.

I doubt it is worth the effort.

Thanks,
Hannes
