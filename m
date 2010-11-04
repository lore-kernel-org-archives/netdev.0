From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 1/1] vhost: TX used buffer guest signal accumulation
Date: Wed, 03 Nov 2010 22:38:46 -0700
Message-ID: <1288849126.12932.4.camel@localhost.localdomain>
References: <1288216693.17571.38.camel@localhost.localdomain>
	 <1288240804.14342.1.camel@localhost.localdomain>
	 <20101028052021.GD5599@redhat.com>
	 <1288286062.11251.15.camel@localhost.localdomain>
	 <20101029081027.GB22688@redhat.com>
	 <1288366988.4110.5.camel@localhost.localdomain>
	 <20101030200603.GA19033@redhat.com>
	 <1288642673.19173.8.camel@localhost.localdomain>
	 <20101103104812.GB10555@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:46728 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754176Ab0KDFit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Nov 2010 01:38:49 -0400
In-Reply-To: <20101103104812.GB10555@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-11-03 at 12:48 +0200, Michael S. Tsirkin wrote:
> I mean in practice, you see a benefit from this patch?

Yes, I tested it. It does benefit the performance.

> > My concern here is whether checking only in set up would be
> sufficient
> > for security?
> 
> It better be sufficient because the checks that put_user does
> are not effictive when run from the kernel thread, anyway.
> 
> > Would be there is a case guest could corrupt the ring
> > later? If not, that's OK.
> 
> You mean change the pointer after it's checked?
> If you see such a case, please holler.

I wonder about it, not a such case in mind.

> To clarify: the combination of __put_user and separate
> signalling is giving the same performance benefit as your
> patch?

Yes, it has similar performance, not I haven't finished all message
sizes comparison yet.

> I am mostly concerned with adding code that seems to help
> speed for reasons we don't completely understand, because
> then we might break the optimization easily without noticing.

I don't think the patch I submited would break up anything. It just
reduced the cost of per used buffer 3 put_user() calls and guest
signaling from one to one to many to one.

Thanks
Shirley

