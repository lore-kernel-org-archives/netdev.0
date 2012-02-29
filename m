From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v4 2/2] netdev: driver: ethernet: Add TI CPSW driver
Date: Tue, 28 Feb 2012 21:04:07 -0800
Message-ID: <1330491847.4352.6.camel@joe2Laptop>
References: <1330490737-28973-1-git-send-email-mugunthanvnm@ti.com>
	 <1330490737-28973-3-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46121 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750713Ab2B2FEJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Feb 2012 00:04:09 -0500
In-Reply-To: <1330490737-28973-3-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-02-29 at 10:15 +0530, Mugunthan V N wrote:
> This patch adds support for TI's CPSW driver.
[]
> +static int cpsw_poll(struct napi_struct *napi, int budget)
> +{
> +	struct cpsw_priv	*priv = napi_to_priv(napi);
> +	int			num_tx, num_rx;
> +
> +	num_tx = cpdma_chan_process(priv->txch, 128);
> +	num_rx = cpdma_chan_process(priv->rxch, budget);
> +
> +	if (num_rx || num_tx)
> +		cpsw_dbg(priv, intr, pr_fmt("poll %d rx, %d tx pkts"),
> +			  num_rx, num_tx);

You don't need pr_fmt() for any of these cpsw_<level> uses.
but you do need a terminating "\n".

> +static int __devinit cpsw_probe(struct platform_device *pdev)
[]
> +	if (!data) {
> +		pr_err("cpsw: platform data missing\n");

Don't need "cpsw: " prefix
