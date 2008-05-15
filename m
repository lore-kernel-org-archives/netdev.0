From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/15] BE NIC driver - interrupt, ethtool, stack i/f functions
Date: Thu, 15 May 2008 13:49:35 +0100
Message-ID: <20080515124933.GK28241@solarflare.com>
References: <20080515090613.03bf6fa6@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Subbu Seetharaman <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:47821 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750752AbYEOMti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 08:49:38 -0400
Content-Disposition: inline
In-Reply-To: <20080515090613.03bf6fa6@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subbu Seetharaman wrote:
> +static int
> +be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
> +{
> +	struct bni_net_object *pnob = netdev->priv;
> +
> +	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
> +	ecmd->advertising = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
> +	ecmd->port = PORT_FIBRE;
> +	ecmd->transceiver = XCVR_EXTERNAL;

This doesn't make a whole lot of sense.  You can't be supporting both
10GBase-T and fibre, but only ever using fibre.  If you don't know what
kind of PHY is attached, you can use MDIO to find out (or maybe query your
firmware or EEPROM).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
