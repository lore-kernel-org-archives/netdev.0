From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3 v3] changes to make ipv4 routing table aware
 of next-hop link status
Date: Wed, 10 Jun 2015 23:19:29 -0400
Message-ID: <20150611031916.GW588@gospo.home.greyhouse.net>
References: <1433990233-958-1-git-send-email-gospo@cumulusnetworks.com>
 <CAE4R7bChX1AtwoeC12ei1hr-3CJnZwPig8YXKpvAuhHSRyVYLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:36344 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbbFKDTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 23:19:32 -0400
Received: by qkx62 with SMTP id 62so34692441qkx.3
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 20:19:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bChX1AtwoeC12ei1hr-3CJnZwPig8YXKpvAuhHSRyVYLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 08:07:10PM -0700, Scott Feldman wrote:
> On Wed, Jun 10, 2015 at 7:37 PM, Andy Gospodarek
> <gospo@cumulusnetworks.com> wrote:
> 
> > There was also a request for switchdev support for this, but that will be
> > posted as a followup as switchdev does not currently handle dead
> > next-hops in a multi-path case and I felt that infra needed to be added
> > first.
> 
> That's not true.  switchdev_fib_ipv4_add() passes *fi and all of the
> nexthops for the route are hanging off of that, including the
> nh->flags where you're setting LINKDOWN.  Multipath is not different
> than singlepath in that regard.  Same API for both.  

The API is the same, but I did not see a path that would take a
multipath route and update the dead nexthops when an interface is taken
down with switchdev or rocker today.

I could be wrong (and I will test again), but create a multipath route
with nexthops on swp1 and swp2 and then call 'ip link set swp1 down' and
let me know if you see rocker's ECMP routes get updated so only the
nexthop on swp2 will be used.
