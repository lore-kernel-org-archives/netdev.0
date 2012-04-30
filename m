From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 5/5] be2net: Fix to allow set/get of debug
 levels in the Firmware.
Date: Mon, 30 Apr 2012 15:13:22 +0100
Message-ID: <1335795202.2685.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <a32d6d08-5428-4bfd-85fc-2ac8d560d5d8@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Suresh Reddy <Suresh.Reddy@emulex.com>
To: Somnath Kotur <somnath.kotur@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:52075 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751500Ab2D3ON1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 10:13:27 -0400
In-Reply-To: <a32d6d08-5428-4bfd-85fc-2ac8d560d5d8@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-30 at 11:35 +0530, Somnath Kotur wrote:
> Suggested-by: Ben Hutchings <bhutchings@solarflare.com>

No, not really.

> Signed-off-by: Suresh Reddy <Suresh.Reddy@emulex.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
[...]
> +static void be_set_msglevel(struct net_device *netdev, u32 data)
> +{
> +	struct be_adapter *adapter = netdev_priv(netdev);
> +	struct be_dma_mem extfat_cmd;
> +	struct be_fat_conf_params *cfgs;
> +	int status;
> +	int i, j;
> +
> +	if (lancer_chip(adapter)) {
> +		dev_err(&adapter->pdev->dev, "Operation not supported\n");
> +		return;
> +	}
> +
> +	switch (data) {
> +	case TRACE_LEVEL_ALL:
> +	case TRACE_LEVEL_ENTER_FUNCTION:
> +	case TRACE_LEVEL_VERBOSE:
> +	case TRACE_LEVEL_INFO:
> +	case TRACE_LEVEL_TEST:
> +	case TRACE_LEVEL_SHOW:
> +	case TRACE_LEVEL_WARNING:
> +	case TRACE_LEVEL_ERROR:
> +	case TRACE_LEVEL_FATAL:
> +	case TRACE_LEVEL_ALWAYS:
> +	case TRACE_LEVEL_DISABLED:
> +		break;
> +	default:
> +		dev_err(&adapter->pdev->dev, "Invalid message level value\n");
> +		return;
> +	}
[...]

So far as I'm concerned, the message 'level' should be a msg_enable
bitmask as used by the 'netif' logging functions.  This convention
hasn't been consistently implemented in existing drivers and still isn't
documented in <linux/ethtool.h>.  But the ethtool utility interprets it
according to this convention, and that was commented as being intended
since at least 2005 (beginning of git history).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
