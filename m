From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] [NET 2.6.26]: Add per-connection option to set max TSOframe   size
Date: Fri, 29 Feb 2008 15:20:20 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC329049C4342@orsmsx414.amr.corp.intel.com>
References: <20080228183150.4431.81252.stgit@localhost.localdomain> <20080229204650.GA2848@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <stephen.hemminger@vyatta.com>,
	<netdev@vger.kernel.org>
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55330 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863AbYB2XWN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 18:22:13 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080229204650.GA2848@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +++ b/include/linux/netdevice.h
> ...
> > +	/* for setting kernel sock attribute on TCP connection setup */
> > +#define GSO_MAX_SIZE		65536
> > +	u32			gso_max_size;
> 
> One more, maybe foolish, thrifty idea: do we really need such 
> a precision here? I don't know those devices, but maybe it 
> would be enough (for the beginning at least?) to use a few 
> divisors e.g.:
> 
> gso_max_size = 65536 >> GSO_MAX_SIZE_SHIFT
> 
> Then it seems 3 or 4 bits should be enough for this, and BTW, 
> it looks like dev->features has 16 bits for various GSO 
> flags, with "a lot" of free space yet - unless I missed something?

This patch has two purposes, one to add an additional tunable for TSO
for drivers, and two, to support buggy hardware that can do segmentation
offloading, but can't handle 64 KB frames.  Your suggestion here would
lend well for the latter, for drivers needing to set the maximum frame
size to something "smaller," and not really needing or wanting fine
granularity.  It just needs something smaller to chew on vs. the current
64 KB frames.

For the tuning, I see the desire for something much more granular.
Looking ahead at some of the giant send offload features coming (support
for TSOs bigger than 64 KB) and even for current adapters looking to
fine tune TSO given a certain workload, I see the need for this
granularity.  For a certain type of workload, a TSO max frame size of 40
KB, or 20 KB, or even 50 KB might be something a driver would like to
do.

Hopefully this clarifies my intent.  I think keeping the full precision
is the right thing to do moving forward.  I really do appreciate the
inputs though, keep them coming please.  :-)

Cheers,
-PJ Waskiewicz
