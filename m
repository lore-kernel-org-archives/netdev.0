From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/9] netdev: bfin_mac: add support for IEEE 1588 PTP
Date: Tue, 11 May 2010 09:07:16 +0200
Message-ID: <20100511070716.GA3254@riccoc20.at.omicron.at>
References: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	uclinux-dist-devel@blackfin.uclinux.org,
	Barry Song <barry.song@analog.com>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57159 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754227Ab0EKHHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 03:07:10 -0400
Received: by fxm19 with SMTP id 19so17028fxm.19
        for <netdev@vger.kernel.org>; Tue, 11 May 2010 00:07:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 10, 2010 at 11:39:06AM -0400, Mike Frysinger wrote:
> diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
> index 587f93c..6a9519f 100644
> --- a/drivers/net/bfin_mac.c
> +++ b/drivers/net/bfin_mac.c
...
> +#define PTP_CLK 25000000
> +
> +static void bfin_mac_hwtstamp_init(struct net_device *netdev)
> +{
> +	struct bfin_mac_local *lp = netdev_priv(netdev);
> +	u64 append;
> +
> +	/* Initialize hardware timer */
> +	append = PTP_CLK * (1ULL << 32);
> +	do_div(append, get_sclk());
> +	bfin_write_EMAC_PTP_ADDEND((u32)append);

It appears that one can tune this PTP clock.

I recently posted a suggestion for a PTP clock class driver. Would you
care to take a look at that and say whether that API would also work
for the blackfin?

Thanks,
Richard

