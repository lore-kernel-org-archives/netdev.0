From: kuznet@ms2.inr.ac.ru
Subject: Re: Fw: [PATCH] IPv6: Allow 6to4 routes with SIT
Date: Tue, 15 Jul 2003 18:28:49 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307151428.SAA08491@dub.inr.ac.ru>
References: <Pine.LNX.4.44.0307150914450.7445-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi (Pekka Savola)
In-Reply-To: <Pine.LNX.4.44.0307150914450.7445-100000@netcore.fi> from "Pekka Savola" at éÀÌ 15, 2003 09:28:11 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

>  1) modify /sbin/ip and /sbin/route (and the rest if any) so that they'll
> parse global next-hop information and resolve it for the kernel, and
> report the resolved information to the kernel (see the other thread)

No, really. It is problem of user to supply reasonable values.
This policy is not forced, because there are many cases when it does not
make sense (f.e. on all the routers, on all the PtP interfaces et al).

Verification of validity of nexthop is to be done only when receiving
nexthop through addrconf or redirect et al. I guess interiour protocols
also should take care of it.


>  2) the kernel supports "must-resolve" next-hops.

I do not know what it is.


> practical situation is rather simple: for the case of a:b in 6to4, they're
> always irrelevant.

Sure. It is becasue use of 6to4 address is meaningless in this context.
It is thought which I try to deliver.


> Note that nothing _prevents_ you from treating a:b in 2002:x:y::a:b

I do not understand the rest.

Listen, tunnel needs an _IPv4_ address for destiantion of tunnel.
Because our routing does not permit to use different address family
as nexthop, we did trick presenting it as an IPv4-compat address.
We could do this differently, f.e. to use FFFF:EEEE:IPv4-addr:CCCC:DDDD
with the same success or any other randomly chosen encapsulation.

And this silly combination is still _better_ than 6to4 address, which
contains redundant information, which can be mixed up with real _IPv6_
6to4 addresses and whihc contains IPv4 address in some place which
used to be identification of a network prefix.



Alexey
