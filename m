From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC ETHTOOL PATCH 2/2] ethtool: allow setting MDI-X state
Date: Thu, 26 Jul 2012 17:35:22 +0100
Message-ID: <1343320522.2770.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120725174351.9839.132.stgit@jbrandeb-snb.jf.intel.com>
	 <20120725175308.9839.50343.stgit@jbrandeb-snb.jf.intel.com>
	 <1343257142.5132.160.camel@deadeye.wl.decadent.org.uk>
	 <20120726163033.GA20122@jbrandeb-snb.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24608 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752144Ab2GZQf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 12:35:26 -0400
In-Reply-To: <20120726163033.GA20122@jbrandeb-snb.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-26 at 09:30 -0700, Jesse Brandeburg wrote:
> On Wed, Jul 25, 2012 at 11:59:02PM +0100, Ben Hutchings wrote:
> > On Wed, 2012-07-25 at 10:53 -0700, Jesse Brandeburg wrote:
> > How about when you have a forced mode but the driver reports eth_tp_mdix
> > = ETH_TP_MDI_INVALID because the link is down?  This is going to result
> > in:
> > 
> >         MDI-X: Unknown (forced)
> > 
> > which makes no sense at all.  So I think that we have to do something
> > like:
> > 
> > 	if (ep->eth_tp_mdix_ctrl == ETH_TP_MDI) {
> > 		fprintf(stdout, "off (forced)\n");
> > 	} else if (ep->eth_tp_mdix_ctrl == ETH_TP_MDI_X) {
> > 		fprintf(stdout, "on (forced)\n");
> > 	} else {
> > 		switch (ep->eth_tp_mdix) {
> > 			...
> > 		}
> > 		if (ep->eth_tp_mdix_ctrl == ETH_TP_MDI_AUTO)
> > 			fprintf(stdout, " (auto)");
> > 		fprintf(stdout, "\n");
> > 	}
> > 
> > Or else we require that when the mode is forced then drivers report that
> > as the current status even if the link is down.
> 
> I tried that and it works swimmingly.  How does this look?
[...]

That looks good, thanks.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
