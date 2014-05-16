From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next] xen-netfront: try linearizing SKB if it
 occupies too many slots
Date: Fri, 16 May 2014 16:34:52 +0100
Message-ID: <20140516153452.GM18551@zion.uk.xensource.com>
References: <1400238496-2471-1-git-send-email-wei.liu2@citrix.com>
 <1400245474.7973.154.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140516131145.GK18551@zion.uk.xensource.com>
 <1400250068.7973.171.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140516143653.GL18551@zion.uk.xensource.com>
 <1400253739.7973.183.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, David Vrabel <david.vrabel@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:22902 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932509AbaEPPfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 11:35:21 -0400
Content-Disposition: inline
In-Reply-To: <1400253739.7973.183.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2014 at 08:22:19AM -0700, Eric Dumazet wrote:
> On Fri, 2014-05-16 at 15:36 +0100, Wei Liu wrote:
> > On Fri, May 16, 2014 at 07:21:08AM -0700, Eric Dumazet wrote:
> > > On Fri, 2014-05-16 at 14:11 +0100, Wei Liu wrote:
> > > 
> > > > It's not that common to trigger this, I only saw a few reports. In fact
> > > > Stefan's report is the first one that comes with a method to reproduce
> > > > it.
> > > > 
> > > > I tested with redis-benchmark on a guest with 256MB RAM and only saw a
> > > > few "failed to linearize", never saw a single one with 1GB guest.
> > > 
> > > Well, I am just saying. This is asking order-5 allocations, and yes,
> > > this is going to fail after few days of uptime, no matter what you try.
> > > 
> > 
> > Hmm... I see what you mean -- memory fragmentation leads to allocation
> > failure. Thanks.
> 
> In the mean time, have you tried to lower gso_max_size ?
> 
> Setting it witk netif_set_gso_max_size() to something like 56000 might
> avoid the problem.
> 
> (Not sure if it is applicable in your case)
> 

It works, at least in this Redis testcase. Could you explain a bit where
this 56000 magic number comes from? :-)

Presumably I can derive it from some constant in core network code?

Wei.

> 
