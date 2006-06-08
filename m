From: "Jari Takkala" <Jari.Takkala@Q9.com>
Subject: Re: [patch 06/17] neighbour.c, pneigh_get_next() skips published entry
Date: Thu, 8 Jun 2006 14:21:16 -0400
Message-ID: <413FEEF1743111439393FB76D0221E4804A56900@leopard.zoo.q9networks.com>
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.q9.com ([216.220.35.253]:53417 "EHLO mx2.q9.com")
	by vger.kernel.org with ESMTP id S964891AbWFHSVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 14:21:18 -0400
Content-class: urn:content-classes:message
To: "David Miller" <davem@davemloft.net>, <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 5 Jun 2006, David Miller wrote:

> This patch doesn't make any sense, I've been over it a few times.
> 
> The seqfile layer should take care of that user buffering issue
transparently as
> long as we implement the interface callbacks properly.
>
> Even if something needs to be fixed in the pneigh dumper, special
casing *pos==1
> doesn't look right.  Also, if pneigh has this problem, how come the
neigh seqfile
> iterators don't have the same problem or do they?

>From my analysis, the problem is that pneigh_get_next() ends up
assigning pn to one entry ahead of what it should be pointing too. This
only occurs when the user's read buffer fills up, where pneigh_get_idx()
is called, which calls pneigh_get_next() until *pos is not true.

I have not checked neigh seqfile iterators, the problem may exist in
there as well. My patch solves this issue for us, however a more elegant
solution would be most welcome.  Could the root of the problem be that
*pos is off by one when pneigh_get_idx() is called?

Jari

