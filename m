From: kuznet@ms2.inr.ac.ru
Subject: Re: Fw: [PATCH] IPv6: Allow 6to4 routes with SIT
Date: Tue, 15 Jul 2003 03:29:12 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307142329.DAA06071@dub.inr.ac.ru>
References: <20030713005345.1fea1092.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20030713005345.1fea1092.davem@redhat.com> from "David S. Miller" at éÀÌ 13, 2003 12:53:45 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Hey guys, even though yoshfuji is away I don't see any
> reason why I shouldn't apply the patch below to both
> 2.4.x and 2.5.x.  It looks very uncontroversial to me.
> 
> Any objections?

I would wait for experts.

Technically IPv6 does not allow use of non-link-local address
as nexthop address, because nexthop address is expected to be unique
for router.

Use of IPv4-COMPAT format for tunnels was a hack to make use of tunnel more
handly, it just a tricky way to encapsulate an IPv4 address inside
IPv6 one, it has nothing to do with _real_ IPv4-COMPAT addresses,
(though logically IPv4-COMPAT addresses _are_ really link-local
for 6over4 "network") it is just an element of our API. Use of 6of4 address
is very strange idea in this context, it does not contradict to anything,
of course, but it looks utterly stupid: 6to4 is a complicated format, where
information about nexthop is encoded in an inapproriate way.
The questions sort of: "What the hell? I do a route with nexthop
2002:x:y::a:b and a:b disappears somewhere." And the question is right,
because plain logic requires to use a:b as meaningful part of nexthop,
it is the part which provides node _identity_, x:y is just routing information,
identifying particullar "6to4" network, it is meaningless when used
as a nexthop address.

Shortly, this is mess. Technically, it is just one more trick and useless one,
logically... mess.

Alexey
