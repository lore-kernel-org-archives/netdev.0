From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/5] be2net: Fix to allow setting of debug
 levels in the firmware.
Date: Thu, 26 Apr 2012 18:29:48 +0100
Message-ID: <1335461388.2712.25.camel@bwh-desktop.uk.solarflarecom.com>
References: <464dcb28-2450-4e0b-a30f-d8c9104bac86@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Somnath Kotur <Somnath.Kotur@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:15729 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752161Ab2DZR3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 13:29:55 -0400
In-Reply-To: <464dcb28-2450-4e0b-a30f-d8c9104bac86@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-26 at 19:57 +0530, Somnath Kotur wrote:
> From: Somnath Kotur <somnath.kotur@emulex.com>
[...]
> @@ -893,6 +959,7 @@ const struct ethtool_ops be_ethtool_ops = {
>  	.set_pauseparam = be_set_pauseparam,
>  	.get_strings = be_get_stat_strings,
>  	.set_phys_id = be_set_phys_id,
> +	.set_msglevel = be_set_msglevel,
>  	.get_sset_count = be_get_sset_count,
>  	.get_ethtool_stats = be_get_ethtool_stats,
>  	.get_regs_len = be_get_reg_len,

This operation is intended for controlling logging by the driver, and
the flags are defined in <linux/netdevice.h>.  (Not exported to userland
yet, but ethtool knows their names.)

If your firmware supports some kind of logging then it may be reasonable
to have this control both driver and firmware, but not *just* the
firmware.

You should also implement the get_msglevel operation at the same time.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
