From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 02/11] benet: interrupt/i/o handling, network layer i/f
 and ethtool functions
Date: Tue, 09 Dec 2008 15:34:27 +0100
Message-ID: <493E81F3.60800@trash.net>
References: <1228832399.6435.95.camel@sperla-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jgarzik@pobox.com,
	jeff@garzik.org, subbu <subbus@serverengines.com>
To: Sathya Perla <sathyap@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65238 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371AbYLIOeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 09:34:31 -0500
In-Reply-To: <1228832399.6435.95.camel@sperla-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sathya Perla wrote:
> +/*
> + * This is the driver entry point to add a vlan vlan_id
> + * with the device netdev
> + */
> +static void benet_vlan_add_vid(struct net_device *netdev, u16 vlan_id)
> +{
> +	struct be_net_object *pnob = netdev->priv;
> +
> +	if (pnob->num_vlans == (BE_NUM_VLAN_SUPPORTED - 1)) {
> +		/* no  way to return an error */
> +		dev_info(&netdev->dev,
> +		       "BladeEngine: Cannot configure more than %d Vlans\n",
> +			       BE_NUM_VLAN_SUPPORTED);
> +		return;

I'd suggest to either make ->vlan_add_vid() return an error code
or disable VLAN hardware filtering completely when you exceed the
number of supported VLANs. The later is probably the better choice
since people expect to be able to add any number of VLANs.

