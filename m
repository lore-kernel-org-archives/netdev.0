From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] tg3: Make the RSS indir tbl admin configurable
Date: Fri, 16 Dec 2011 19:43:39 +0000
Message-ID: <1324064619.2798.17.camel@bwh-desktop>
References: <1323996466-8139-1-git-send-email-mcarlson@broadcom.com>
	 <1324004674.2825.226.camel@deadeye>
	 <20111216191927.GA9054@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51923 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760537Ab1LPTnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 14:43:43 -0500
In-Reply-To: <20111216191927.GA9054@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-12-16 at 11:19 -0800, Matt Carlson wrote:
> On Thu, Dec 15, 2011 at 07:04:34PM -0800, Ben Hutchings wrote:
> > On Thu, 2011-12-15 at 16:47 -0800, Matt Carlson wrote:
> > > This patch adds the ethtool callbacks necessary to change the rss
> > > indirection table from userspace.  When setting the indirection table
> > > through set_rxfh_indir, an indirection table size of zero is
> > > interpreted to mean that the admin wants to relinquish control of the
> > > table to the driver.  Should the number of interrupts change (e.g.
> > > across a close / open call, or through a reset), any indirection table
> > > values that exceed the number of RSS queues or interrupt vectors will
> > > be automatically scaled back to values within range.
> > > 
> > > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > 
> > No I didn't!
> > 
> > Ben.
> 
> Sorry.  This part of procedure I'm unsure about.  I didn't want to lose
> the ack of your contributions to this patch.  The SOB does imply that
> you are O.K. with it as-is though, which you may or may not be aligned
> with.  I apologize if I was putting words in your mouth.
> 
> What should I have done instead?  Would Dave put the SOB on your behalf
> as he accepts it?
[...]

If you really want to credit me for the tiny change I suggested, just
put that in free-form.  But I'm afraid you'll have to respin this
completely, as David applied my changes to centralise validation and the
default policy.  I think instead of adding the USER_INDIR_TBL flag you
could reasonably reset the table to default whenever the interface is
brought up and you fail to get the wanted number of IRQs.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
