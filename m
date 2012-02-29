From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/4] net: ethtool: add the EEE support
Date: Wed, 29 Feb 2012 17:00:23 +0000
Message-ID: <1330534823.2519.12.camel@bwh-desktop>
References: <1330433084-18586-1-git-send-email-peppe.cavallaro@st.com>
	  <1330433084-18586-3-git-send-email-peppe.cavallaro@st.com>
	 <1330443900.8460.158.camel@deadeye> <4F4E4E6A.7090000@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:56594 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964977Ab2B2RA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 12:00:28 -0500
In-Reply-To: <4F4E4E6A.7090000@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-02-29 at 17:12 +0100, Giuseppe CAVALLARO wrote:
> Hello Ben,
> 
> On 2/28/2012 4:45 PM, Ben Hutchings wrote:
> > On Tue, 2012-02-28 at 13:44 +0100, Giuseppe CAVALLARO wrote:
[...]
> >> @@ -937,6 +940,8 @@ struct ethtool_ops {
> >>  				 struct ethtool_dump *, void *);
> >>  	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
> >>  
> >> +	int	(*get_eee) (struct net_device *, struct ethtool_value *);
> >> +	int	(*set_eee) (struct net_device *, struct ethtool_value *);
> > [...]
> > 
> > Why are there new operations as well as a new field to ethtool_cmd?
> > 
> > Is the value a boolean or a bitmask?
> 
> the former.
> These are for enabling/disabling the EEE and also to get the status.
> 
> > Since EEE is an auto-negotiated feature, why aren't you defining flags
> > for the supported/advertising/lp_advertising fields?
> 
> I added these because the stmmac needs to have a timer to enter in LPI
> tx mode. So this can be stopped by using ethtool.
> I didn't define flags for supported/advertising/lp_advertising because
> these are fixed in the RO MMD register and it makes no sense to modify
> them (hmm, I think :-)).

It is certainly necessary to distinguish:
a. PHY is advertising EEE
from
b. Link partner is advertising EEE
or
c. EEE will be used (= a && b)

I haven't had anything to do with PHY drivers for a while but it looks
like you should be able to map MDIO register 3.20 to supported flags,
7.60 to advertising and 7.61 to lp_advertising.

Even if your particular device doesn't support these MDIO registers,
other devices will.  So I think you should define the flags and then if
you don't have that fine control you should check in your set_settings
implementation that the advertising value either has all the EEE mode
flags clear or has all the modes the hardware supports set.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
