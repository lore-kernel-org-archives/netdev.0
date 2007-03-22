From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [ANN] Unified dynamic storage for different socket types instead of separate hash tables.
Date: Thu, 22 Mar 2007 22:30:52 +0300
Message-ID: <20070322193051.GB1181@2ka.mipt.ru>
References: <20070322185944.GA3802@2ka.mipt.ru> <20070322.120346.41643926.davem@davemloft.net> <20070322191449.GA25274@2ka.mipt.ru> <20070322.122120.115923509.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51166 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934196AbXCVTbb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 15:31:31 -0400
Content-Disposition: inline
In-Reply-To: <20070322.122120.115923509.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2007 at 12:21:20PM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Thu, 22 Mar 2007 22:14:49 +0300
> 
> > And to be absolutely clear - existing interface does not support it too
> > - we iterate over every single hash entry, and then over every single
> > item in the chain (if it exists). I can create the same for the tree -
> > it is not complex at all, but it is not the most optimal solution, and 
> > since I remove several entries, I think it is not that bad to remove a 
> > bit less and optimize 'iterate over all object' case a bit.
> 
> This results in your trie having two new run-time costs:
> 
> 1) More expensive trie insert/delete compared to hash
>    insert/delete

That's true, it requires additional allocation, which can be combined
with socket allocation though.

> 2) An extra list insert/delete to give list of all sockets

That is too small price.
And as I stated in another mail - we can iterate over whole tree just
like we do with hash tables - even faster, if I will attach a bitmask of
used entires to each level node.

> So connection setup/teardown will be more expensive and
> therefore our connection rates will be lower.

Hmm, I'm not sure - we already allocate several items during connection
setup/teardown time (request socket, usual socket, timewait socket), 
so additional one is not absolutely sure will end up with slower times.

And do not forget about other benefits dynamic structure gives us
compared to static hash table in DoS and traversal speed/locking.

> Evgeniy, your ideas are beautiful in theory, but all the details
> kill all of your non-trivial work and make it useless in the end.

I especially agree with first part of the sentence :))
So far I can not see serious disadvantages in this design.

-- 
	Evgeniy Polyakov
