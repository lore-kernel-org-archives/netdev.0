From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Add ethtool to mii advertisment conversion helpers
Date: Thu, 17 Nov 2011 01:29:42 +0000
Message-ID: <1321493382.2709.94.camel@bwh-desktop>
References: <1321394453-21076-1-git-send-email-mcarlson@broadcom.com>
	 <1321490078.2709.86.camel@bwh-desktop>
	 <20111117011604.GA8683@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:47278 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754910Ab1KQB3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 20:29:46 -0500
In-Reply-To: <20111117011604.GA8683@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-16 at 17:16 -0800, Matt Carlson wrote:
> On Wed, Nov 16, 2011 at 04:34:37PM -0800, Ben Hutchings wrote:
[...]
> > > +#define mii_lpa_to_ethtool_100bt(lpa)	mii_adv_to_ethtool_100bt(lpa)
> > 
> > Shouldn't this additionally translate LPA_LPACK into ADVERTISED_Autoneg?
> 
> You mean, like this?
> 
> static inline u32 mii_lpa_to_ethtool_100bt(u32 lpa)
> {
> 	u32 result = 0;
> 
> 	if (lpa & LPA_LPACK)
> 		result |= ADVERTISED_Autoneg;
> 
> 	return result | mii_adv_to_ethtool_100bt(lpa);
> }
> 
> Yes, that looks like a better implementation.

Think so.

And I think the mii_adv_to_ethtool_* functions should add
ADVERTISED_Autoneg unconditionally.  But I'm not entirely sure that's
right.

> > [...]
> > > +static inline u32 mii_lpa_to_ethtool_1000T(u32 lpa)
> > [...]
> > > +static inline u32 ethtool_adv_to_mii_1000X(u32 ethadv)
> > [...]
> > > +static inline u32 mii_adv_to_ethtool_1000X(u32 adv)
> > [...]
> > 
> > I'm not convinced about the naming convention for these.  Would it not
> > make more sense to name them consistently by register name and signal
> > type:
> > 
> > ethtool_adv_to_mii_adv_t
> > mii_adv_to_ethtool_adv_t
> > ethtool_adv_to_mii_ctrl1000_t
> > mii_ctrl1000_to_ethtool_adv_t
> > mii_lpa_to_ethtool_lpa_t
> > mii_stat1000_to_ethtool_lpa_t
> > ethtool_adv_to_mii_adv_x
> > mii_adv_to_ethtool_adv_x
> 
> I don't have a strong preference either way.  I'll post the change along
> with the above modification.
> 
> > Shouldn't there be mii_lpa_to_ethtool_1000X (or
> > mii_lpa_to_ethtool_lpa_x)?
> 
> Yes.  You're right.  Should it just be a preprocessor definition that
> points to mii_adv_to_ethtool_1000X()?

I think that would need to handle LPA_LPACK as well.

> > Finally, do these need to be inline?
> 
> I don't have a strong preference here either.  Phy code tends to be
> slower, so there isn't really a strong performance argument.  The
> implementations don't seem to be so large to argue against it though.
> Would you prefer they not be inlined?

I suppose one of us should measure what difference it makes to code
size.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
