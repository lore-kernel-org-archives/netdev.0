From: Phil Sutter <phil@nwl.cc>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Thu, 4 May 2017 22:43:18 +0200
Message-ID: <20170504204318.GB21130@orbyte.nwl.cc>
References: <20170503235638.31116-1-stephen@networkplumber.org>
 <590AF624.6090808@iogearbox.net>
 <7315b681-9c78-4bc1-ab74-64509ab5887d@gmail.com>
 <20170504.104103.1628291573330660235.davem@davemloft.net>
 <20170504094356.66590a9a@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dsahern@gmail.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45047 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750710AbdEDUnU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 16:43:20 -0400
Content-Disposition: inline
In-Reply-To: <20170504094356.66590a9a@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, May 04, 2017 at 09:43:56AM -0700, Stephen Hemminger wrote:
> On Thu, 04 May 2017 10:41:03 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: David Ahern <dsahern@gmail.com>
> > Date: Thu, 4 May 2017 08:27:35 -0600
> > 
> > > On 5/4/17 3:36 AM, Daniel Borkmann wrote:  
> > >> What is the clear benefit/rationale of outsourcing this to
> > >> libmnl? I always was the impression we should strive for as little
> > >> dependencies as possible?  
> > > 
> > > +1  
> > 
> > Agreed, all else being equal iproute2 should be as self contained
> > as possible since it is such a fundamental tool.
> 
> Sorry, the old netlink code is more difficult to understand than libmnl.
> Having dependency on a library is not a problem. There already is
> an alternative implementation of ip commands in busybox for those
> people trying to work in small environments.

I second that. If you can't afford the extra ~24KB of libmnl on your
system, you much rather can't afford the 20 times bigger ip binary,
either.

Regarding conversion to libmnl, which I investigated and started working
on once: My gut feeling back then was that it's not quite worth the
effor since iproute2 requires an intermediate layer of functions anyway.
Another detail which I didn't like that much was libmnl's idiom of
creating netlink messages on base of just a plain buffer and using
mnl_nlmsg_put_header() et al. to populate it with data. I'm probably a
bit biased since I did the conversion to c99-style initializers for the
various struct req data types, but I didn't like the added run-time
overhead to achieve just the same.

So in summary, given that very little change happens to iproute2's
internal libnetlink, I don't see much urge to make it use libmnl as
backend. In my opinion it just adds another potential source of errors.

Eventually this should be a maintainer level decision, though. :)

Cheers, Phil
