From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 5/5] alx: add stats to ethtool
Date: Thu, 2 Jan 2014 18:23:05 +0000
Message-ID: <1388686985.9947.22.camel@bwh-desktop.uk.level5networks.com>
References: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
	 <1388619628-3373-6-git-send-email-sd@queasysnail.net>
	 <1388664091.22017.17.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <johannes@sipsolutions.net>,
	<netdev@vger.kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50460 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176AbaABSXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 13:23:09 -0500
In-Reply-To: <1388664091.22017.17.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 12:01 +0000, Ben Hutchings wrote:
> On Thu, 2014-01-02 at 00:40 +0100, Sabrina Dubroca wrote:
> > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > ---
> >  drivers/net/ethernet/atheros/alx/ethtool.c | 95 ++++++++++++++++++++++++++++++
> >  1 file changed, 95 insertions(+)
> > 
> > diff --git a/drivers/net/ethernet/atheros/alx/ethtool.c b/drivers/net/ethernet/atheros/alx/ethtool.c
> > index 45b3650..259056f 100644
> > --- a/drivers/net/ethernet/atheros/alx/ethtool.c
> > +++ b/drivers/net/ethernet/atheros/alx/ethtool.c
> [...]
> > +static void alx_get_ethtool_stats(struct net_device *netdev,
> > +				  struct ethtool_stats *estats, u64 *data)
> > +{
> > +	struct alx_priv *alx = netdev_priv(netdev);
> > +	struct alx_hw *hw = &alx->hw;
> > +
> > +	spin_lock(&alx->stats_lock);
> > +
> > +	__alx_update_hw_stats(hw);
> > +	memcpy(data, &hw->stats, sizeof(hw->stats));
> 
> This definitely doesn't work if the members of hw->stats are typed as
> unsigned long...
[...]

Also it would be a good idea to assert the sizes match here:

	BUILD_BUG_ON(sizeof(hw->stats) != ALX_NUM_STATS * sizeof(u64));

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
