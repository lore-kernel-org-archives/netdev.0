From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3 v3] changes to make ipv4 routing table aware
 of next-hop link status
Date: Wed, 10 Jun 2015 23:33:31 -0400
Message-ID: <20150611033331.GY588@gospo.home.greyhouse.net>
References: <1433990233-958-1-git-send-email-gospo@cumulusnetworks.com>
 <CAE4R7bChX1AtwoeC12ei1hr-3CJnZwPig8YXKpvAuhHSRyVYLg@mail.gmail.com>
 <20150611031916.GW588@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34872 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbbFKDdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 23:33:35 -0400
Received: by qkhq76 with SMTP id q76so34828742qkh.2
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 20:33:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150611031916.GW588@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 11:19:29PM -0400, Andy Gospodarek wrote:
> On Wed, Jun 10, 2015 at 08:07:10PM -0700, Scott Feldman wrote:
> > On Wed, Jun 10, 2015 at 7:37 PM, Andy Gospodarek
> > <gospo@cumulusnetworks.com> wrote:
> > 
> > > There was also a request for switchdev support for this, but that will be
> > > posted as a followup as switchdev does not currently handle dead
> > > next-hops in a multi-path case and I felt that infra needed to be added
> > > first.
> > 
> > That's not true.  switchdev_fib_ipv4_add() passes *fi and all of the
> > nexthops for the route are hanging off of that, including the
> > nh->flags where you're setting LINKDOWN.  Multipath is not different
> > than singlepath in that regard.  Same API for both.  
> 
> The API is the same, but I did not see a path that would take a
> multipath route and update the dead nexthops when an interface is taken
> down with switchdev or rocker today.
> 
> I could be wrong (and I will test again), but create a multipath route
> with nexthops on swp1 and swp2 and then call 'ip link set swp1 down' and
> let me know if you see rocker's ECMP routes get updated so only the
> nexthop on swp2 will be used.
> 

Scott, as I stated before I have every intention of adding switchdev as well
as ipv6 support and at this point I hope people know I'm good fot it.
Since I'm already on v3 of the ipv4 support that is looking like a good
idea.  :)  I'm sure you can empathize as you have organically grown the
switchdev support in the kernel.
