From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: vlan 03/07: Add ethtool support
Date: Tue, 8 Jul 2008 14:54:16 +0100
Message-ID: <20080708135415.GH28029@solarflare.com>
References: <20080707123557.23947.70114.sendpatchset@localhost.localdomain> <20080707123601.23947.96915.sendpatchset@localhost.localdomain> <20080707165217.GC28029@solarflare.com> <48724B81.2070708@trash.net> <20080707172119.GD28029@solarflare.com> <48725698.1030809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.mbr-roch.zen.net.uk ([212.23.3.142]:34074 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752276AbYGHNyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 09:54:19 -0400
Content-Disposition: inline
In-Reply-To: <48725698.1030809@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Ben Hutchings wrote:
> >Patrick McHardy wrote:
> >>Ben Hutchings wrote:
> >>>Patrick McHardy wrote:
> >>>>vlan: Add ethtool support
> >>>>
> >>>>Add ethtool support for querying the device for offload settings.
> >>>>
> >>>>Signed-off-by: Patrick McHardy <kaber@trash.net>
> >>>[...]
> >>>>+static u32 vlan_ethtool_get_rx_csum(struct net_device *dev)
> >>>>+{
> >>>>+	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
> >>>>+	struct net_device *real_dev = vlan->real_dev;
> >>>>+
> >>>>+	if (real_dev->ethtool_ops == NULL ||
> >>>>+	    real_dev->ethtool_ops->get_rx_csum == NULL)
> >>>>+		return 0;
> >>>>+	return real_dev->ethtool_ops->get_rx_csum(real_dev);
> >>>But we don't know whether RX checksum offload applies to VLAN-tagged
> >>>packets (or, admittedly, any specific protocol).  It would be nice if 
> >>>there
> >>>was a feature flag for this so it could be advertised in vlan_features.
> >>True, for now the assumption is that it works for VLANs.
> >>I don't think that assumption is unreasonable, but I can
> >>look into a separate flag for this.
> >
> >I would be surprised if there aren't some NICs that only check frames with
> >protocol/length set to ETH_P_IP.
> 
> Yes, probably. But this is only informational and it won't be
> any wronger than on the device itself. So no big deal I'd say,
> but if you prefer I can also remove the TX csum support.

As I said there's no way to see which protocols RX csum offload works for
anyway, so just showing whether it's enabled on the physical device is no
worse than the current behaviour for physical devices.

> >>>Can't we also add:
> >>>
> >>>	.get_tx_csum		= ethtool_op_get_tx_csum,
> >>>	.get_sg			= ethtool_op_get_sg,
> >>>	.get_tso		= ethtool_op_get_tso,
> >>>	.get_flags		= ethtool_op_get_flags,
> >>Besides get_flags all of these are handled by default handlers.
> >
> >So they are.
> >
> >>What is get_flags used for?
> >
> >Currently only LRO, but potentially other offload features.
> 
> LRO is currently not supported by the VLAN code, at least
> not directly (drivers supporting VLAN accel can do VLAN
> LRO though). So for now it seems useless to add it.

If the physical device driver is doing VLAN LRO then doesn't it make sense
to expose this in the VLAN device?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
