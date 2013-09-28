From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 path MTU discovery broken
Date: Sat, 28 Sep 2013 23:19:49 +0200
Message-ID: <20130928211949.GD23654@order.stressinduktion.org>
References: <20130927201420.GB12043@sesse.net> <20130928203318.GC23654@order.stressinduktion.org> <20130928205131.GB20124@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, edumazet@google.com
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57564 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755083Ab3I1VTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 17:19:50 -0400
Content-Disposition: inline
In-Reply-To: <20130928205131.GB20124@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 28, 2013 at 10:51:31PM +0200, Steinar H. Gunderson wrote:
> On Sat, Sep 28, 2013 at 10:33:18PM +0200, Hannes Frederic Sowa wrote:
> >> Could this be related somehow to the packets coming from 2001:67c:=
29f4::31,
> >> while the default route is to a link-local address? (An RPF issue?=
) This used
> >> to work (although it was often flaky for me) in 3.10 and before. I=
 can't
> >> easily bisect, though, as I don't boot this machine too often.
> > This looks like a bug and should definitely get fixed. There should=
 be
> > no RPF issue. May I have a look at your /proc/net/ipv6_route?
>=20
> Hi,
>=20
> I removed all the =E2=80=9Cweird=E2=80=9D routes, and confirmed it fi=
xed the problem.
> However, upon adding them back again, the problem was still gone
> (despite flushing the route cache).
>=20
> This means that the issue has gone back to being intermittent, which =
is of
> course the worst kind of bug to trace down. :-) I'll dump
> /proc/net/ipv6_route and send you once I see the bug manifest itself =
again,
> OK?

Yes, that would be very helpful.

Also, you can try to churn up your bgp connection a bit so that the fib
serial numbers get incremented a lot (drop and install new routes). Whe=
n
tcp_ipv6 processes the icmp errors it will drop the in-socket cached
routing entry then and will reinstall a relookuped one.  This is my onl=
y
suspect currently. If that would help to reproduce the problem the susp=
ects
would be the changes in the next-hop selection. Sorry, no other idea
currently.

Thanks,

  Hannes
