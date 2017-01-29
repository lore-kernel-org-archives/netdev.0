From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] qed: Add infrastructure for PTP support.
Date: Sun, 29 Jan 2017 16:31:34 +0100
Message-ID: <20170129153134.GC2223@localhost.localdomain>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-2-git-send-email-Sudarsana.Kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, Yuval.Mintz@cavium.com
To: Sudarsana Kalluru <Sudarsana.Kalluru@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34618 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751229AbdA2Pbi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 10:31:38 -0500
Received: by mail-wm0-f68.google.com with SMTP id c85so71214930wmi.1
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 07:31:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1485674903-27689-2-git-send-email-Sudarsana.Kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 28, 2017 at 11:28:22PM -0800, Sudarsana Kalluru wrote:
> +/* Read Rx timestamp */
> +static int qed_ptp_hw_read_rx_ts(struct qed_dev *cdev, u64 *timestamp)
> +{
> +	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
> +	struct qed_ptt *p_ptt = p_hwfn->p_ptp_ptt;
> +	u32 val;
> +
> +	*timestamp = 0;
> +	val = qed_rd(p_hwfn, p_ptt, NIG_REG_LLH_PTP_HOST_BUF_SEQID);
> +	if (!(val & QED_TIMESTAMP_MASK)) {
> +		DP_INFO(p_hwfn, "Invalid Rx timestamp, buf_seqid = %d\n", val);
> +		return -EINVAL;
> +	}
> +
> +	val = qed_rd(p_hwfn, p_ptt, NIG_REG_LLH_PTP_HOST_BUF_TS_LSB);
> +	*timestamp = qed_rd(p_hwfn, p_ptt, NIG_REG_LLH_PTP_HOST_BUF_TS_MSB);

You can already "Reset timestamp register to allow new timestamp" at
this point, before combining the MSB and LSB.

> +	*timestamp <<= 32;
> +	*timestamp |= val;
> +
> +	/* Reset timestamp register to allow new timestamp */
> +	qed_wr(p_hwfn, p_ptt, NIG_REG_LLH_PTP_HOST_BUF_SEQID,
> +	       QED_TIMESTAMP_MASK);
> +
> +	return 0;
> +}

Thanks,
Richard
