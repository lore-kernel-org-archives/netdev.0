From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific qdisc
Date: Thu, 2 Nov 2006 12:16:57 +0000
Message-ID: <20061102121657.GA13468@infradead.org>
References: <20061026050416.GB14199@havoc.gtf.org> <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net> <20061101112805.246e1b3b@griffin.suse.cz> <20061101142022.GC21668@tuxdriver.com> <4548E7F7.7030100@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Simon Barber <simon@devicescape.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34968 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1752622AbWKBMR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 07:17:26 -0500
To: James Ketrenos <jketreno@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <4548E7F7.7030100@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 01, 2006 at 10:31:19AM -0800, James Ketrenos wrote:
> The only merge requirement should be that merging d80211 doesn't break
> existing in-tree wireless drivers.  We have that today -- you can have
> both stacks in the tree and running in parallel.  With that, we have the
> ability to migrate over time.
> 
> The other 'merge requirements' are functionally irrelevant.  We know the
> d80211 stack is where wireless on Linux is going -- the sooner steps are
> taken to get that stack out to the masses the faster it can be adopted
> and improved.
> 

We had that discussion offline last week, but let's repeat it here for
the general public.

The most important merge requirement is to not break userspace.  That means
proper support of WE (hopefully via cfg80211), and a single ethX network
device.  The second most important is proper smp support, or good code
quality in general.  We can't afford to merge buggy code.  Third most
important is to make sure it's a full replacment for the current ieee80211
code - for the softmac cards that's mostly trivial, but the half-hard mac
old intel cards are hard.  That's where intel comes into play because you
support that hardware _and_ are pushing for d80211.  That makes your team
pretty much volunteer to fix that up in my eyes.

