From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 1/1] vhost: TX used buffer guest signal accumulation
Date: Thu, 4 Nov 2010 11:30:45 +0200
Message-ID: <20101104093045.GA27506@redhat.com>
References: <1288216693.17571.38.camel@localhost.localdomain>
 <1288240804.14342.1.camel@localhost.localdomain>
 <20101028052021.GD5599@redhat.com>
 <1288286062.11251.15.camel@localhost.localdomain>
 <20101029081027.GB22688@redhat.com>
 <1288366988.4110.5.camel@localhost.localdomain>
 <20101030200603.GA19033@redhat.com>
 <1288642673.19173.8.camel@localhost.localdomain>
 <20101103104812.GB10555@redhat.com>
 <1288849126.12932.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27110 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755585Ab0KDJbC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Nov 2010 05:31:02 -0400
Content-Disposition: inline
In-Reply-To: <1288849126.12932.4.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 03, 2010 at 10:38:46PM -0700, Shirley Ma wrote:
> On Wed, 2010-11-03 at 12:48 +0200, Michael S. Tsirkin wrote:
> > I mean in practice, you see a benefit from this patch?
> 
> Yes, I tested it. It does benefit the performance.
> 
> > > My concern here is whether checking only in set up would be
> > sufficient
> > > for security?
> > 
> > It better be sufficient because the checks that put_user does
> > are not effictive when run from the kernel thread, anyway.
> > 
> > > Would be there is a case guest could corrupt the ring
> > > later? If not, that's OK.
> > 
> > You mean change the pointer after it's checked?
> > If you see such a case, please holler.
> 
> I wonder about it, not a such case in mind.
> 
> > To clarify: the combination of __put_user and separate
> > signalling is giving the same performance benefit as your
> > patch?
> 
> Yes, it has similar performance, not I haven't finished all message
> sizes comparison yet.
> 
> > I am mostly concerned with adding code that seems to help
> > speed for reasons we don't completely understand, because
> > then we might break the optimization easily without noticing.
> 
> I don't think the patch I submited would break up anything.

No, I just meant that when a patch gives some benefit, I'd like
to understand where the benefit comes from so that I don't
break it later.

> It just
> reduced the cost of per used buffer 3 put_user() calls and guest
> signaling from one to one to many to one.

One thing to note is that deferred signalling needs to be
benchmarked with old guests which don't orphan skbs on xmit
(or disable orphaning in both networking stack and virtio-net).

> 
> Thanks
> Shirley

OK, so I guess I'll queue the __put_user etc patches for net-next, on top of this
I think a patch which defers signalling would be nice to have,
then we can figure out whether a separate heads array still has benefits
for non zero copy case: if yes what they are, if no whether it should be
used for zero copy only for both both non-zero copy and zero copy.

Makes sense?

-- 
MST
