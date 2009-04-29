From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [Patch 1/1][RFC] NETDEV: Find network bugs by validating the
	sk_buff state
Date: Wed, 29 Apr 2009 15:28:09 -0700
Message-ID: <20090429222809.GA1949@cuplxvomd02.corp.sa.net>
References: <20090429040501.GA32074@cuplxvomd02.corp.sa.net> <20090428.223058.119960146.davem@davemloft.net> <20090429151440.GA14266@cuplxvomd02.corp.sa.net> <20090429.145338.149717676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:55316 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761964AbZD2W2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 18:28:10 -0400
Content-Disposition: inline
In-Reply-To: <20090429.145338.149717676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2009 at 02:53:38PM -0700, David Miller wrote:
> From: David VomLehn <dvomlehn@cisco.com>
> Date: Wed, 29 Apr 2009 08:14:40 -0700
> 
> > On Tue, Apr 28, 2009 at 10:30:58PM -0700, David Miller wrote:
> >> 
> >> Sorry, for this to be useful distributions are going to turn it on by
> >> default, and adding 24 bytes to struct sk_buff on 64-bit when we're
> >> trying everything in our power to make it smaller rather than larger
> >> is not acceptable.
> > 
> > That's like saying that any of the kernel debugging options have to be on
> > by default.  I expect that most folks won't want this on unless they are
> > looking for a bug. 
> 
> We don't have networking buffer structure elements that implement
> debugging, and it's for a reason.

Can I assume this is due to the concern, stated below, that distributions will
start turning it on?

> > Right. This is why it depends on KERNEL_DEBUG and why it is off by default.
> 
> All of this is moot if distributions decide to start turning this
> on, and from my experience they will.

This puzzles me.

It will cost performance and memory if distros turn this on, and they
aren't idiots.  How can we know enough to determine for all distributions
whether the paypack is enough to permanently enable a particular kernel
debugging feature?

Still, let us back up to technical specifics. There is a need for kernel
debugging features and experience shows that the networking area is no
exception. So:

	What criteria must network debugging features meet for kernel
	inclusion, considered first as a kernel debugging feature, and
	second, as a non-optional consistency check?

Memory and performance are obvious choices for criteria, what would the
threshholds be here? Are there other criteria?

Note that I'm happy to consider making it *more* expensive to use a feature
if the case can be made that:
1. The feature must not be used in production
2. The feature becomes expensive enough to prevent its use in production

David VomLehn
