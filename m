From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Mon, 28 Oct 2013 12:30:39 +0100
Message-ID: <20131028113039.GE31491@secunet.com>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de>
 <3169911.kTmZ0BZVVr@h2o.as.studentenwerk.mhn.de>
 <1382547992.7572.31.camel@edumazet-glaptop.roam.corp.google.com>
 <5743349.5WGxWa1M1u@ei.h3.stusta.mhn.de>
 <20131025080158.GC31491@secunet.com>
 <1382691028.7572.78.camel@edumazet-glaptop.roam.corp.google.com>
 <20131025092043.GD31491@secunet.com>
 <1382941051.13037.13.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfgang Walter <linux@stwm.de>,
	David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:59284 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755818Ab3J1Lao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Oct 2013 07:30:44 -0400
Content-Disposition: inline
In-Reply-To: <1382941051.13037.13.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 27, 2013 at 11:17:31PM -0700, Eric Dumazet wrote:
> On Fri, 2013-10-25 at 11:20 +0200, Steffen Klassert wrote:
> > On Fri, Oct 25, 2013 at 01:50:28AM -0700, Eric Dumazet wrote:
> > > 
> > > 32768 as the default seems fine to me
> > > 
> > > 448 bytes per dst -> thats less than 30 Mbytes of memory if we hit 65536
> > > dst.
> > > 
> > 
> > Ok, I'll add the patch below to to the ipsec tree if everyone is fine
> > with that threshold.
> > 
> > Subject: [PATCH RFC] xfrm: Increase the garbage collector threshold
> > 
> > With the removal of the routing cache, we lost the
> > option to tweak the garbage collector threshold
> > along with the maximum routing cache size. So git
> > commit 703fb94ec ("xfrm: Fix the gc threshold value
> > for ipv4") moved back to a static threshold.
> > 
> > It turned out that the current threshold before we
> > start garbage collecting is much to small for some
> > workloads, so increase it from 1024 to 32768. This
> > means that we start the garbage collector if we have
> > more than 32768 dst entries in the system and refuse
> > new allocations if we are above 65536.
> > 
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> > ---
> 
> Sure please add :
> 
> Reported-by: Wolfgang Walter <linux@stwm.de>

Done.

Now applied to the ipsec tree, thanks everyone!
