From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3] tg3: Make the RSS indir tbl admin configurable
Date: Fri, 16 Dec 2011 22:58:38 +0000
Message-ID: <1324076318.2798.27.camel@bwh-desktop>
References: <1324074791-10463-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:23641 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752634Ab1LPW6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 17:58:42 -0500
In-Reply-To: <1324074791-10463-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-12-16 at 14:33 -0800, Matt Carlson wrote:
> This patch adds the ethtool callbacks necessary to change the rss
> indirection table from userspace.  Should the number of interrupts
> change (e.g.  across a close / open call, or through a reset) and
> any one of the indirection table values fall out-of-range, the driver
> will reset the indirection table to a default layout.
> 
> [Integrated many suggestions made by Ben Hutchings.]
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Just a nitpick:

[...]
> +static int tg3_get_rxfh_indir(struct net_device *dev, u32 *indir)
> +{
> +	struct tg3 *tp = netdev_priv(dev);
> +	int i;
> +
> +	if (!tg3_flag(tp, SUPPORT_MSIX))
> +		return -EOPNOTSUPP;

The above check is not needed, because we promise not to to call
get_rxfh_indir() if get_rxfh_indir_size() returns 0.

> +	for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++)
> +		indir[i] = tp->rss_ind_tbl[i];
> +
> +	return 0;
> +}
> +
> +static int tg3_set_rxfh_indir(struct net_device *dev, const u32 *indir)
> +{
> +	struct tg3 *tp = netdev_priv(dev);
> +	size_t i;
> +
> +	if (!tg3_flag(tp, SUPPORT_MSIX))
> +		return -EOPNOTSUPP;
[...]

Same for this one.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
