From: Bill Fink <billfink@mindspring.com>
Subject: Re: 2.6.20.7 TCP cubic (and bic) initial slow start way too slow?
Date: Sat, 12 May 2007 12:07:39 -0400
Message-ID: <20070512120739.371ada4f.billfink@mindspring.com>
References: <20070509023131.70e2cc45.billfink@mindspring.com>
	<20070510113215.f5ff2d34.billfink@mindspring.com>
	<2994.152.14.88.74.1178822365.squirrel@webmail.ncsu.edu>
	<20070510.133522.99205764.davem@davemloft.net>
	<20070510134547.7ec30308@freepuppy>
	<002301c79345$c45ffd00$4a580e98@ncsu2cc0c3fa00>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>, <rhee@ncsu.edu>,
	<sangtae.ha@gmail.com>, <netdev@vger.kernel.org>
To: "Injong Rhee" <rhee@eos.ncsu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:35158 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756243AbXELQHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2007 12:07:53 -0400
In-Reply-To: <002301c79345$c45ffd00$4a580e98@ncsu2cc0c3fa00>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 May 2007, Injong Rhee wrote:

> Oops. I thought Bill was using 2.6.20 instead of 2.6.22 which should contain 
> our latest update.

I am using 2.6.20.7.

> Regarding slow start behavior, the latest version should not change though. 
> I think it would be ok to change the slow start of bic and cubic to the 
> default slow start. But what we observed is that when BDP is large, 
> increasing cwnd by two times is really an overkill. consider increasing from 
> 1024 into 2048 packets..maybe the target is somewhere between them. We have 
> potentially a large number of packets flushed into the network. That was the 
> original motivation to change slow start from the default into a more gentle 
> version. But I see the point that Bill is raising. We are working on 
> improving this behavior in our lab. We will get back to this topic in a 
> couple of weeks after we finish our testing and produce a patch.

Is it feasible to replace the version of cubic in 2.6.20.7 with the
new 2.1 version of cubic without changing the rest of the kernel, or
are there kernel changes/dependencies that would prevent that?

I've tried building and running a 2.6.21-git13 kernel, but am having
some difficulties.  I will be away the rest of the weekend so won't be
able to get back to this until Monday.

						-Bill

P.S.  When getting into the the 10 Gbps range, I'm not sure there's
      any way to avoid the types of large increases during "slow start"
      that you mention, if you want to achieve those kinds of data
      rates.



> ----- Original Message ----- 
> From: "Stephen Hemminger" <shemminger@linux-foundation.org>
> To: "David Miller" <davem@davemloft.net>
> Cc: <rhee@ncsu.edu>; <billfink@mindspring.com>; <sangtae.ha@gmail.com>; 
> <netdev@vger.kernel.org>
> Sent: Thursday, May 10, 2007 4:45 PM
> Subject: Re: 2.6.20.7 TCP cubic (and bic) initial slow start way too slow?
> 
> 
> > On Thu, 10 May 2007 13:35:22 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> >
> >> From: rhee@ncsu.edu
> >> Date: Thu, 10 May 2007 14:39:25 -0400 (EDT)
> >>
> >> >
> >> > Bill,
> >> > Could you test with the lastest version of CUBIC? this is not the 
> >> > latest
> >> > version of it you tested.
> >>
> >> Rhee-sangsang-nim, it might be a lot easier for people if you provide
> >> a patch against the current tree for users to test instead of
> >> constantly pointing them to your web site.
> >> -
> >
> > The 2.6.22 version should have the latest version, that I know of.
> > There was small patch from 2.6.21 that went in.
