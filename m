From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Re: SFQ depth limit
Date: Thu, 24 Jul 2008 11:57:15 +0200
Message-ID: <488851FB.4080407@trash.net>
References: <200806282202.59581.denys@visp.net.lb> <20080629191113.GA8817@ami.dom.local> <20080723.213443.37820788.davem@davemloft.net> <48884133.8070301@trash.net> <20080724094908.GA3946@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, denys@visp.net.lb,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62616 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbYGXJ5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 05:57:21 -0400
In-Reply-To: <20080724094908.GA3946@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Thu, Jul 24, 2008 at 10:45:39AM +0200, Patrick McHardy wrote:
>>
>> I'm not sure we should do this, this removes the symetry between
>> ->init/change and ->dump. Its not a big deal in this case since
>> flows is unused in ->init anyway, but still its a not so nice
>> precedent. Such things should normally be put in the statistics.
>
> 
> Hmm... I didn't even notice this. But I guess, this patch didn't
> introduce this precedent since this non-config "flow" was dumped
> before. 

Yes, thats true, but see below.

> Btw., I can see e.g. direct_pkts in htb_dump() which looks
> like similar precedent.

Ugh, yes, that also should have been in the statistics.

> IMHO, printing the same thing 2x under
> different names is worse precedent. Anyway, this patch isn't any
> big deal, so I can send a revert.

I think its not exactly 2x the same thing. "flows" has a different
meaning than limit (its the depth), but because its hardcoded its
not parsed in ->init. And because of implementation details "flows"
is limited by "limit", which itself is limited by the hardcoded
depth, so they just happen to always have the same value. Using
the current number of *active* flows doesn't really match the
original meaning anymore. IIRC the ESFQ for SFQ patches even use
"flows" in ->init, so it might make things a bit more ugly if we
ever merge those patches.

