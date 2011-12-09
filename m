From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-next 4/6] tg3: Track LP advertising
Date: Thu, 8 Dec 2011 16:14:53 -0800
Message-ID: <20111209001453.GA31557@mcarlson.broadcom.com>
References: <1323381002-31565-5-git-send-email-mcarlson@broadcom.com>
 <1323385565.3094.3.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1511 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751227Ab1LIAOU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 19:14:20 -0500
In-Reply-To: <1323385565.3094.3.camel@bwh-desktop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2011 at 03:06:05PM -0800, Ben Hutchings wrote:
> On Thu, 2011-12-08 at 13:50 -0800, Matt Carlson wrote:
> > This patch adds code to track the autonegotiation advertisements of the
> > link partner and report them through ethtool.
> > 
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Reviewed-by: Michael Chan <mchan@broadcom.com>
> > ---
> >  drivers/net/ethernet/broadcom/tg3.c |   41 ++++++++++++++++++++++++++++++++--
> >  drivers/net/ethernet/broadcom/tg3.h |    1 +
> >  2 files changed, 39 insertions(+), 3 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> > index d1681db..ae1e838 100644
> > --- a/drivers/net/ethernet/broadcom/tg3.c
> > +++ b/drivers/net/ethernet/broadcom/tg3.c
> > @@ -3803,6 +3803,29 @@ static bool tg3_phy_copper_an_config_ok(struct tg3 *tp, u32 *lcladv)
> >  	return true;
> >  }
> >  
> > +static bool tg3_phy_copper_fetch_rmtadv(struct tg3 *tp, u32 *rmtadv)
> > +{
> > +	u32 val, lpeth = 0;
> > +
> > +	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY)) {
> > +		if (tg3_readphy(tp, MII_STAT1000, &val))
> > +			return false;
> > +
> > +		lpeth = mii_stat1000_to_ethtool_lpa_t(val);
> > +	}
> > +
> > +	if (tg3_readphy(tp, MII_LPA, &val))
> > +		return false;
> > +
> > +	lpeth |= mii_lpa_to_ethtool_lpa_t(val);
> > +	tp->link_config.rmt_adv = lpeth;
> > +
> > +	if (tg3_flag(tp, PAUSE_AUTONEG))
> > +		*rmtadv = val;
> 
> I assume that the caller only needs this information if pause autoneg is
> enabled, but it's still very strange to put the condition here.

I see your point.  I'm being overly cautious.  I'll respin this patch.

> Ben.
> 
> > +	return true;
> > +}
> [...]
> 
> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
