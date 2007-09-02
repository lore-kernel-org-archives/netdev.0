From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2]: [NET_SCHED]: Making rate table lookups more flexible.
Date: Sun, 02 Sep 2007 23:16:54 +0200
Message-ID: <46DB2846.2030400@trash.net>
References: <1188562978.18622.13.camel@localhost.localdomain> <46D91082.7050609@trash.net> <Pine.LNX.4.61.0709012338320.29796@ask.diku.dk> <46DACA48.2060602@trash.net> <Pine.LNX.4.61.0709022006380.20071@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57621 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759588AbXIBVSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 17:18:30 -0400
In-Reply-To: <Pine.LNX.4.61.0709022006380.20071@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Dangaard Brouer wrote:
> On Sun, 2 Sep 2007, Patrick McHardy wrote:
>>
>>> This is not a ATM/ADSL only patch.  This patch simply adds more
>>> flexibility to the rate tables.  Afterwards we can start the discussion
>>> about how to use this new flexibility in tc/iproute2.
>>
>> I know, but that discussion should happen *before* merging any
>> changes to the kernel.
>
> Let not try to solve too many things at once. We need to do this in 
> small steps. Please, lets not start long and borrowing discussion 
> again, where we try to solve too many things at once.

We don't need many, but we do need *one* thing that actually
uses this and isn't controversial before merging.
>
>
>> Its pointless to add functionality that
>> won't be used afterwards or may need to be done differently.
>
> I believe that the functionality _will_ be used, also in the general 
> case.
>
> Lets focus on the general case, where the functionality actually is 
> needed right away.
>
> In the general case:
>
> - The rate table needs to be aligned (cell_align=-1).
>   (currently, we miscalculates up to 7 bytes on every lookup)

We will always do that, thats a consequence of storing the
transmission times for multiples of 8b.

>
> - The existing tc overhead calc can be made more accurate.
>   (by adding overhead before doing the lookup, instead of the
>    current solution where the rate table is modified with its
>    limited resolution)

Please demonstrate this with patches (one for the overhead
calculation, one for the cell_align thing), then we can
continue this discussion.

>
>
> Patrick, note that your STAB solution will _not_ work without the rate 
> table alignment.


I can't argue about this without looking into it again first,
but it shouldn't really matter for now since we don't have
a patch to actually implement it.


