From: jamal <hadi@cyberus.ca>
Subject: Re: TODO list before feature freeze
Date: Tue, 30 Jul 2002 08:29:49 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0207300818480.15727-100000@shell.cyberus.ca>
References: <20020730142758.A492@oknodo.bof.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andi Kleen <ak@suse.de>, Rusty Russell <rusty@rustcorp.com.au>,
   <netfilter-devel@lists.netfilter.org>, <netdev@oss.sgi.com>,
   <netfilter-core@lists.netfilter.org>
Return-path: <owner-netdev@oss.sgi.com>
To: Patrick Schaaf <bof@bof.de>
In-Reply-To: <20020730142758.A492@oknodo.bof.de>
List-Id: netdev.vger.kernel.org



On Tue, 30 Jul 2002, Patrick Schaaf wrote:

> > What i have seen and reported by many people (someone seems to have gone
> > one step further and documented numbers, but cant find his email right
> > now). Take Linux as a router, it routes at x% of wire rate. Load
> > conntracking and watch it go down another 25% at least.
>
> Unfortunately, this is insufficient information to pin down what was
> happening. As Andi Kleen mentioned, a simple kernel profile from such
> a test would be a good start.
>

Dont have time -- if i did youd probably see a patch from me. I gave you
the testcase, you go do it.
Infact you dont even need to be forwarding to reproduce this. Marc Boucher
has a small udp traffic generator; you can use that on the lo device
and reproduce this.

> Most likely things leading to such a result, in no specific suborder:
>
> - skb linearization
> - always-defragment
> - ip_conntrack_lock contention
> - per-packet timer management
>
> I'm not personally interested in line rate routing, but I look forward
> to further results from such setups. I concentrate on real server work-
> loads, because that's where my job is.
>

Has nothing to do with forwarding (Marcs tool is a client-server setup)
You only need one or two flows. I am almost certain that if
you solve that simple case, you end up solving the larger problem.

> > I think hashing is one of the problems. What performance improvemet are
> > you seeing? (couldnt tell from looking at your data)
>
> We found that the autosizing tends to make the bucket count a multiple
> of two, and we found the currently used hash function does not like
> that, resulting in longer average bucket list lengths than neccessary.
> The crc32 hashes, and suitable modified abcd hashes, don't suffer from
> this deficiency, and they are almost identical to random (a pseudohash
> I used to depict the optimum).
>
> However, the "badness" of the current hash, given my datasets, results
> in less than one additional list element, on average. So we could save
> one memory roundtrip. Given that with my netfilter hook statistics patch,
> I see >3000 cycles (1Ghz processor) spent in ip_conntrack_in - about
> 10 memory round-trips - I don't think that you could measure the hash
> function improvement, except for artificial test cases.
>
> We can improve here, but not much. Changing the hash function is mostly
> interesting to make hash bucket length attacks more unlikely.  The abcd
> hash family, with boottime chosen multipliers, could be of use here.
>

I think this is a good start, but insufficient; in general i think you
are looking at the wrong thing. Hashing is an issue, no doubt but i
dont think it is the main issue. Did you start chasing hashing because you
saw some large numbers in profiles? If i was to use instinct i would say
the last two items you list are probably the things you may want to chase.

cheers,
jamal
