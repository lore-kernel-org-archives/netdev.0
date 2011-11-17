From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH] Add ethtool to mii advertisment conversion helpers
Date: Wed, 16 Nov 2011 18:06:13 -0800
Message-ID: <20111117020613.GA18232@mcarlson.broadcom.com>
References: <1321394453-21076-1-git-send-email-mcarlson@broadcom.com>
 <1321490078.2709.86.camel@bwh-desktop>
 <20111117011604.GA8683@mcarlson.broadcom.com>
 <1321493382.2709.94.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2064 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754928Ab1KQCFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 21:05:23 -0500
In-Reply-To: <1321493382.2709.94.camel@bwh-desktop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2011 at 05:29:42PM -0800, Ben Hutchings wrote:
> On Wed, 2011-11-16 at 17:16 -0800, Matt Carlson wrote:
> > On Wed, Nov 16, 2011 at 04:34:37PM -0800, Ben Hutchings wrote:
> [...]
> > > > +#define mii_lpa_to_ethtool_100bt(lpa)	mii_adv_to_ethtool_100bt(lpa)
> > > 
> > > Shouldn't this additionally translate LPA_LPACK into ADVERTISED_Autoneg?
> > 
> > You mean, like this?
> > 
> > static inline u32 mii_lpa_to_ethtool_100bt(u32 lpa)
> > {
> > 	u32 result = 0;
> > 
> > 	if (lpa & LPA_LPACK)
> > 		result |= ADVERTISED_Autoneg;
> > 
> > 	return result | mii_adv_to_ethtool_100bt(lpa);
> > }
> > 
> > Yes, that looks like a better implementation.
> 
> Think so.
> 
> And I think the mii_adv_to_ethtool_* functions should add
> ADVERTISED_Autoneg unconditionally.  But I'm not entirely sure that's
> right.

The primary purpose of these functions is to translate the information
between two representations.  It seems wise to be careful not to add
from it or take anything away from it.  It is certainly possible to
have a valid AN advertisement register configuration, but not have
autoneg enabled.  Keeping the ADVERTISED_Autoneg out could prevent
misuse.  Do you agree?

> > > Shouldn't there be mii_lpa_to_ethtool_1000X (or
> > > mii_lpa_to_ethtool_lpa_x)?
> > 
> > Yes.  You're right.  Should it just be a preprocessor definition that
> > points to mii_adv_to_ethtool_1000X()?
> 
> I think that would need to handle LPA_LPACK as well.

I was wondering if that was present in 1000Base-X mode.  I didn't see it
in my passing glance at a spec.
