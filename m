From: "Krishna Kumar" <kumarkr@us.ibm.com>
Subject: Re: [PATCH]  IPv6 Prefix List support for 2.5.31
Date: Thu, 29 Aug 2002 11:28:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <8866.85186201266$1030645847@news.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Hi Alexey,

Thanks for your detailed response. I have included my comments to the
points
you have raised below :

> > - Routing table will have lots of address prefixes that are not
available
> >   to the local interface addresses.
>
> Well, all the direct routes are prefixes by definition.

I had written in my previous mail "More code needs to be present to parse
each
entry in this case.", which is what I think you have also implied. Eg, for
each
routing entry, you need to make sure it is the same device, that it is not
a
Link Local destination, and there is no 'next hop' field.

> > - To be a prefix list entry, it should come via an RA.
>
> Wrong. But this does not matter, RA routes may be tagged with a flag.

I disagree about the first part :-) A user can add an address with a new
prefix, but that should not be present in the list of prefixes supported
on that subnet. The prefix list should contain elements that a RA has
advertised as part of the prefixes that the router supports. The RFC is
specific about how prefix list entries are to be created (eg 6.3.4).

Regarding the second point you made about the 'flag', I agree with you, and
I did say something to that effect in my previous mail :

        "Then the only solution to figure out that this is not a real
Prefix
         entry would involve more code to  determine if this is an RA added
         routing entry or a manual one."

> > -  Also, the search over a longer routing table across all nodes is
more
> >    time consuming.
>
> Do you jest? You compare linear search with lookup in radix tree. :-)

Since there is no key to lookup, you have to always walk the entire tree
(the
key is an address/prefix, but we don't have it). I think it would be faster
in
the case where the routing table is very large, and there aren't too many
interfaces (haven't defined "too many" here :-). The number of prefixes on
an
interface is not important for the search property.

The difference is that in case of routing table lookup, you go through the
entire tree and parse each entry, while in the proposed approach, the
linear
search is only done to locate the 'dev' and then the work is more
straightforward - return all entries after getting the correct 'dev'.

I agree that the Prefix List could be implemented on either the idev list
OR
the routing table, we just need to agree which is better place to put the
list.

Thanks,

- KK
