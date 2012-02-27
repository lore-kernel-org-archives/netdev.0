From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3] lpc32xx: Added ethernet driver
Date: Mon, 27 Feb 2012 09:57:29 -0800
Message-ID: <1330365449.9942.26.camel@joe2Laptop>
References: <1330364539-23152-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	alexander.h.duyck@intel.com, eilong@broadcom.com,
	ian.campbell@citrix.com, netdev@vger.kernel.org,
	w.sang@pengutronix.de, linux-kernel@vger.kernel.org,
	kevin.wells@nxp.com, linux-arm-kernel@lists.infradead.org,
	arnd@arndb.de, baruch@tkos.co.il
To: Roland Stigge <stigge@antcom.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:45736 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753354Ab2B0R5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Feb 2012 12:57:31 -0500
In-Reply-To: <1330364539-23152-1-git-send-email-stigge@antcom.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-02-27 at 18:42 +0100, Roland Stigge wrote:
> This patch adds an ethernet driver for the LPC32xx ARM SoC.

This looks nicer to me, thanks.
Just a few more trivial comments.

[]
> +++ linux-2.6/drivers/net/ethernet/nxp/lpc_eth.c
[]
> +static int lpc_mdio_read(struct mii_bus *bus, int phy_id, int phyreg)
> +{
> +	struct netdata_local *pldat = bus->priv;
> +	unsigned long timeout = jiffies + ((HZ * 100) / 1000); /* 100mS */

msecs_to_jiffies?

> +static void __lpc_handle_xmit(struct net_device *ndev)
> +{
[]
> +		/* Any errors occurred? */
> +		if (txstat & 0x80000000) {
> +			if (txstat & 0x20000000) {

It might be clearer to use #defines

> +				/* FIFO underrun */
> +				ndev->stats.tx_fifo_errors++;
> +				ndev->stats.tx_errors++;
> +			}
> +			if (txstat & 0x10000000) {
> +				/* Late collision */
> +				ndev->stats.tx_aborted_errors++;
> +				ndev->stats.tx_errors++;

double counting tx_errors?
