From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 2/3] cxgb4: Add PTP Hardware Clock (PHC) support
Date: Mon, 10 Jul 2017 21:23:54 +0200
Message-ID: <20170710192354.dyd2gr5wt6m7wksf@localhost.localdomain>
References: <1499166982-4875-1-git-send-email-atul.gupta@chelsio.com>
 <1499166982-4875-3-git-send-email-atul.gupta@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, ganeshgr@chelsio.com
To: Atul Gupta <atul.gupta@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35187 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753497AbdGJTYA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 15:24:00 -0400
Received: by mail-wr0-f194.google.com with SMTP id z45so27185681wrb.2
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 12:23:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1499166982-4875-3-git-send-email-atul.gupta@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 04, 2017 at 04:46:21PM +0530, Atul Gupta wrote:
> +/**
> + * cxgb4_ptp_init - initialize PTP for devices which support it
> + * @adapter: board private structure
> + *
> + * This function performs the required steps for enabling PTP support.
> + */
> +void cxgb4_ptp_init(struct adapter *adapter)
> +{
> +	struct timespec64 now;
> +	 /* no need to create a clock device if we already have one */
> +	if (!IS_ERR_OR_NULL(adapter->ptp_clock))
> +		return;
> +
> +	adapter->ptp_tx_skb = NULL;
> +	adapter->ptp_clock_info = cxgb4_ptp_clock_info;
> +	spin_lock_init(&adapter->ptp_lock);
> +
> +	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_clock_info,
> +						&adapter->pdev->dev);
> +	if (!adapter->ptp_clock) {
> +		dev_err(adapter->pdev_dev,
> +			"PTP %s Clock registration has failed\n", __func__);
> +		return;
> +	}

This is wrong.  To quote the header file:

/**
 * ptp_clock_register() - register a PTP hardware clock driver
 *
 * @info:   Structure describing the new clock.
 * @parent: Pointer to the parent device of the new clock.
 *
 * Returns a valid pointer on success or PTR_ERR on failure.  If PHC
 * support is missing at the configuration level, this function
 * returns NULL, and drivers are expected to gracefully handle that
 * case separately.
 */

As this has already been merged, please submit a patch to properly
handle both PTR_ERR and NULL.

Thanks,
Richard
