From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Fw: [PATCH] IPv6: Allow 6to4 routes with SIT
Date: Tue, 15 Jul 2003 22:26:21 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307152029580.14070-100000@netcore.fi>
References: <200307151428.SAA08491@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <jmorris@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307151428.SAA08491@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2003 kuznet@ms2.inr.ac.ru wrote:
> >  1) modify /sbin/ip and /sbin/route (and the rest if any) so that they'll
> > parse global next-hop information and resolve it for the kernel, and
> > report the resolved information to the kernel (see the other thread)
> 
> No, really. It is problem of user to supply reasonable values.

Such addresses are link-locals, of link local scope only.  A link-local 
IPv6 address is awfully difficult to remember and type for all of your 
possible links.

The only reasonable value user could supply is a global address.  If the 
user doesn't have to supply anything .. that's another thing.

> Listen, tunnel needs an _IPv4_ address for destiantion of tunnel.
> Because our routing does not permit to use different address family
> as nexthop, we did trick presenting it as an IPv4-compat address.
> We could do this differently, f.e. to use FFFF:EEEE:IPv4-addr:CCCC:DDDD
> with the same success or any other randomly chosen encapsulation.
> 
> And this silly combination is still _better_ than 6to4 address, which
> contains redundant information, which can be mixed up with real _IPv6_
> 6to4 addresses and whihc contains IPv4 address in some place which
> used to be identification of a network prefix.

Note that what is redundant information in certain scenarios for the
*kernel* may not be redundant information for the *user*.

Please describe what you mean by "real IPv6 6to4 addresses".

If the node processing those as a next-hop supports 6to4 and has the sit0
pseudointerface configured, the address will be but through the special
handling.

If the node doesn't support 6to4 or doesn't have the sit0 pseudointerface 
configured, the address will be processed as normal, as any other IPv6 
nexthop.

Right?

I fail to see what's the fuss about redundant information.  

Redundant information can be ignored.  This is not computer science
theory, removing everything which is not directly relevant.  The use of
the same representation for the next-hop (2002:F00:BA::x) as an address
(2002:BA:F00:y) is the only logical, user-friendly way.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
