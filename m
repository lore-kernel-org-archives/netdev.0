From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Fw: [PATCH] IPv6: Allow 6to4 routes with SIT
Date: Tue, 15 Jul 2003 09:28:11 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307150914450.7445-100000@netcore.fi>
References: <200307142329.DAA06071@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <jmorris@redhat.com>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307142329.DAA06071@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2003 kuznet@ms2.inr.ac.ru wrote:
> > Hey guys, even though yoshfuji is away I don't see any
> > reason why I shouldn't apply the patch below to both
> > 2.4.x and 2.5.x.  It looks very uncontroversial to me.
> > 
> > Any objections?
> 
> I would wait for experts.
> 
> Technically IPv6 does not allow use of non-link-local address
> as nexthop address, because nexthop address is expected to be unique
> for router.

I think we have two choices here:

 1) modify /sbin/ip and /sbin/route (and the rest if any) so that they'll
parse global next-hop information and resolve it for the kernel, and
report the resolved information to the kernel (see the other thread)

 2) the kernel supports "must-resolve" next-hops.

> Use of IPv4-COMPAT format for tunnels was a hack to make use of tunnel more
> handly, it just a tricky way to encapsulate an IPv4 address inside
> IPv6 one, it has nothing to do with _real_ IPv4-COMPAT addresses,
> (though logically IPv4-COMPAT addresses _are_ really link-local
> for 6over4 "network") it is just an element of our API. Use of 6of4 address
> is very strange idea in this context, it does not contradict to anything,
> of course, but it looks utterly stupid: 6to4 is a complicated format, where
> information about nexthop is encoded in an inapproriate way.
> The questions sort of: "What the hell? I do a route with nexthop
> 2002:x:y::a:b and a:b disappears somewhere." And the question is right,
> because plain logic requires to use a:b as meaningful part of nexthop,
> it is the part which provides node _identity_, x:y is just routing information,
> identifying particullar "6to4" network, it is meaningless when used
> as a nexthop address.

Apart from architectural purity (I agree it's messy), I think the
practical situation is rather simple: for the case of a:b in 6to4, they're
always irrelevant.  They always refer to the same next-hop whatever
information you'll put in there, the implementations won't care (because
as a next-hop, it's just a way of saying "the router at address
2002:V4ADDR".

Note that nothing _prevents_ you from treating a:b in 2002:x:y::a:b as a
meaningful part of the nexthop.  They'll just always refer to the same
node for whatever a:b you use.  Note that the prefix length of
2002:x:y::a:b is /16 -- you should really rewrite your next-hop
considerations with s/a:b/x:y::a:b/.

I think the problem for of implementation is that "6to4" technique has
just been hacked in (but quite nicely).  It's a bit, but not much, more
special than that IMO.
 
-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
