From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH] ethtool: Resolve use of uninitialized memory in
 rxclass_get_dev_info
Date: Tue, 17 Jul 2012 16:32:44 +0100
Message-ID: <1342539164.2698.5.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120713165221.28140.92681.stgit@gitlad.jf.intel.com>
	 <1342469017.2523.33.camel@bwh-desktop.uk.solarflarecom.com>
	 <5004AD60.9090702@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60696 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753248Ab2GQPcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 11:32:47 -0400
In-Reply-To: <5004AD60.9090702@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-16 at 17:10 -0700, Alexander Duyck wrote:
> On 07/16/2012 01:03 PM, Ben Hutchings wrote:
> > On Fri, 2012-07-13 at 09:55 -0700, Alexander Duyck wrote:
> >> The ethtool function for getting the rule count was not zeroing out the
> >> data field before passing it to the kernel.  As a result the value started
> >> uninitialized and was incorrectly returning a result indicating that
> >> devices supported setting new rule indexes.  In order to correct this I am
> >> adding a one line fix that sets data to zero before we pass the command to
> >> the kernel.
> > Right.  For 'get' commands with no parameters (besides the device) the
> > data copied back to userland is normally zero-initialised and then
> > filled out by the driver, and I seem to have worked on that assumption.
> > But because of the odd multiplexing of RX NFC commands
> > ETHTOOL_GRXCLSRLCNT doesn't work like that.  And for 'my' driver that
> > didn't matter.  Sorry about that.
> >
> > (We should really have some explicit documentation of responsibility for
> > structure initialisation.)
> >
> >> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> >> ---
> >>
> >> I am resending this since I didn't see any notification that it had been seen.
> >> I also realized that I had not clearly identified that this is an ethtool user
> >> space patch and not an ethtool kernel space patch.
> > It was perfectly clear and I had queued it up to review but hadn't yet
> > done so.
> >
> > Ben.
> >
> Yeah, that was my mistake.  I thought I hadn't sent it out with the
> ethtool prefix when I actually had.

So, anyway, I've applied it and just done a bug fix release (3.4.2).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
