From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH] ixgb: Convert to new vlan model.
Date: Tue, 14 Dec 2010 19:15:21 +0000
Message-ID: <1292354121.20458.11.camel@bwh-desktop>
References: <1292298163-30343-1-git-send-email-jesse@nicira.com>
	 <1292344315.20458.6.camel@bwh-desktop>
	 <EA929A9653AAE14F841771FB1DE5A136602D675056@rrsmsx501.amr.corp.intel.com>
	 <1292350359.20458.8.camel@bwh-desktop>
	 <EA929A9653AAE14F841771FB1DE5A136602D6751C1@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@nicira.com>, David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:16912 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759626Ab0LNTPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 14:15:24 -0500
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A136602D6751C1@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-12-14 at 12:08 -0700, Tantilov, Emil S wrote:
> Ben Hutchings wrote:
> > On Tue, 2010-12-14 at 11:09 -0700, Tantilov, Emil S wrote:
> >> Ben Hutchings wrote:
> >>> On Mon, 2010-12-13 at 19:42 -0800, Jesse Gross wrote:
> >>>> This switches the ixgb driver to use the new vlan interfaces.
> >>>> In doing this, it completes the work begun in
> >>>> ae54496f9e8d40c89e5668205c181dccfa9ecda1 allowing the use of
> >>>> hardware vlan insertion without having a vlan group configured.
> >>>> [...] diff --git a/drivers/net/ixgb/ixgb_ethtool.c
> >>>> b/drivers/net/ixgb/ixgb_ethtool.c
> >>>> index 43994c1..0e4c527 100644
> >>>> --- a/drivers/net/ixgb/ixgb_ethtool.c
> >>>> +++ b/drivers/net/ixgb/ixgb_ethtool.c
> >>>> @@ -706,6 +706,45 @@ ixgb_get_strings(struct net_device *netdev,
> >>>> u32  stringset, u8 *data)  	} } 
> >>>> 
> >>>> +static int ixgb_set_flags(struct net_device *netdev, u32 data) +{
> >>>> +	struct ixgb_adapter *adapter = netdev_priv(netdev); +	bool
> >>>> need_reset; +	int rc; +
> >>>> +	/* The hardware requires that RX vlan stripping and TX vlan
> >>>> insertion +	 * be configured together.  Therefore, if one setting
> >>>> changes adjust the +	 * other one to match. +	 */
> >>>> +	if (!!(data & ETH_FLAG_RXVLAN) != !!(data & ETH_FLAG_TXVLAN)) {
> >>>> +		if ((data & ETH_FLAG_RXVLAN) !=
> >>>> +		    (netdev->features & NETIF_F_HW_VLAN_RX))
> >>>> +			data ^= ETH_FLAG_TXVLAN;
> >>>> +		else if ((data & ETH_FLAG_TXVLAN) !=
> >>>> +		    (netdev->features & NETIF_F_HW_VLAN_TX))
> >>>> +			data ^= ETH_FLAG_RXVLAN;
> >>>> +	}
> >>> [...]
> >>> 
> >>> I think this should reject attempts to change just one flag with
> >>> -EINVAL, rather than quietly 'fixing' the setting.
> >>> 
> >>> Ben.
> >> 
> >> I'm not sure this is a good idea. At least not without some sort of
> >> explanation. Since there is no way for the user to know that he needs
> >> to disable both.
> > 
> > Document the limitation in Documentation/networking/ixgb.txt.  You
> > could also send a patch for the ethtool manual page stating that this
> > restriction might exist.
> > 
> > Ben.
> 
> Just to make sure it's clear - there is no hard requirement for both 
> settings to be set at the same time. So setting:
> ethtool -K eth0 rxvlan off
> 
> Is a valid setting and will disable stripping on Rx, but because of 
> the design, stripping on Tx will also be disabled.

Then it's *not* a valid setting for your hardware/driver.

[...]
> Either way we should update the docs as it is not intuitive.

Yes.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

