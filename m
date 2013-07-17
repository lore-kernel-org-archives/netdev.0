From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] igb: Expose RSS indirection table for ethtool
Date: Wed, 17 Jul 2013 18:03:32 +0100
Message-ID: <1374080612.3861.13.camel@bwh-desktop.uk.level5networks.com>
References: <1374043806-17284-1-git-send-email-laura.vasilescu@rosedu.org>
	 <1374043806-17284-2-git-send-email-laura.vasilescu@rosedu.org>
	 <1374079940.3861.10.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jeffrey.t.kirsher@intel.com>,
	<carolyn.wyborny@intel.com>, <anjali.singhai@intel.com>
To: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51256 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932620Ab3GQRDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 13:03:36 -0400
In-Reply-To: <1374079940.3861.10.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-17 at 17:52 +0100, Ben Hutchings wrote:
[...]
> > +static int igb_get_rss_table(struct net_device *netdev, u32 *rxfh_indir_tbl)
> > +{
> > +	struct igb_adapter *adapter = netdev_priv(netdev);
> > +	struct e1000_hw *hw = &adapter->hw;
> > +	int i;
> > +
> > +	for (i = 0; i < IGB_RETA_SIZE; i++)
> > +		rxfh_indir_tbl[i] = rd32(E1000_RETA(i));
> 
> Unpack each register into entries i*4, i*4+1, i*4+2, i*4+3.
> 
> > +
> > +	return 0;
> > +}
> > +
> > +static int igb_set_rss_table(struct net_device *netdev, const u32 *rxfh_indir_tbl)
> > +{
> > +	struct igb_adapter *adapter = netdev_priv(netdev);
> > +	struct e1000_hw *hw = &adapter->hw;
> > +	int i;
> > +
> > +	for (i = 0; i < IGB_RETA_SIZE; i++)
> > +		wr32(E1000_RETA(i), rxfh_indir_tbl[i]);
> 
> Pack entries i*4, i*4+1, i*4+2, i*4+3 into each register (as in
> igb_setup_mrqc()).
[...]

Also, the indirection table should be preserved in the driver across
hardware resets, although it may need to be reset if the number of RX
queues changes.

Commit 90415477bf13 'tg3: Make the RSS indir tbl admin configurable' is
a good example of how to do this properly.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
