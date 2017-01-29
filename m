From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] qede: Add driver support for PTP.
Date: Sun, 29 Jan 2017 16:35:36 +0100
Message-ID: <20170129153536.GD2223@localhost.localdomain>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-3-git-send-email-Sudarsana.Kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, Yuval.Mintz@cavium.com
To: Sudarsana Kalluru <Sudarsana.Kalluru@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35942 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750990AbdA2Pfl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 10:35:41 -0500
Received: by mail-wm0-f67.google.com with SMTP id r126so71358378wmr.3
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 07:35:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1485674903-27689-3-git-send-email-Sudarsana.Kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 28, 2017 at 11:28:23PM -0800, Sudarsana Kalluru wrote:
> +/**
> + * qede_ptp_adjfreq
> + * @ptp: the ptp clock structure
> + * @ppb: parts per billion adjustment from base
> + *
> + * Adjust the frequency of the ptp cycle counter by the
> + * indicated ppb from the base frequency.
> + */
> +static int qede_ptp_adjfreq(struct ptp_clock_info *info, s32 ppb)
> +{
> +	struct qede_ptp *ptp = container_of(info, struct qede_ptp, clock_info);
> +	struct qede_dev *edev = ptp->edev;
> +	int rc;
> +
> +	__qede_lock(edev);
> +	if (edev->state == QEDE_STATE_OPEN) {
> +		spin_lock_bh(&ptp->lock);
> +		rc = ptp->ops->adjfreq(edev->cdev, ppb);

Why add this extra layer of indirection?

You could put these this test into qed_ptp_hw_adjfreq() and register
that function directly.

> +		spin_unlock_bh(&ptp->lock);
> +	} else {
> +		DP_ERR(edev, "PTP adjfreq called while interface is down\n");
> +		return -EFAULT;
> +	}
> +	__qede_unlock(edev);
> +
> +	return rc;
> +}

Thanks,
Richard
