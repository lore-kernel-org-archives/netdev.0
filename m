From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/7] net: xgmac: add basic framework for Samsung 10Gb
 ethernet driver
Date: Wed, 05 Mar 2014 08:11:58 -0800
Message-ID: <1394035918.3271.67.camel@joe-AO722>
References: <007b01cf3866$009f1900$01dd4b00$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org, davem@davemloft.net,
	siva.kallam@samsung.com, vipul.pandya@samsung.com,
	ks.giri@samsung.com, ilho215.lee@samsung.com
To: Byungho An <bh74.an@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0023.hostedemail.com ([216.40.44.23]:48963 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751630AbaCEQMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 11:12:09 -0500
In-Reply-To: <007b01cf3866$009f1900$01dd4b00$%an@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-05 at 20:28 +0900, Byungho An wrote:
> From: Siva Reddy <siva.kallam@samsung.com>

Just a few trivial comments on a brief scan.

> +/* Context descriptor structure */
> +struct xgmac_tx_ctxt_desc {
> +	u32 tstamp_lo:32;
> +	u32 tstamp_hi:32;

I think u32 foo:32; is odd at best
and may cause compiler oddities.

> diff --git a/drivers/net/ethernet/samsung/xgmac_main.c b/drivers/net/ethernet/samsung/xgmac_main.c
[]
> +static void print_pkt(unsigned char *buf, int len)
> +{
> +	int j;
> +	pr_debug("len = %d byte, buf addr: 0x%p", len, buf);
> +	for (j = 0; j < len; j++) {
> +		if ((j % 16) == 0)
> +			pr_debug("\n %03x:", j);
> +		pr_debug(" %02x", buf[j]);
> +	}
> +	pr_debug("\n");
> +}

This will make a mess.  Use print_hex_dump_debug.

> +static int xgmac_open(struct net_device *dev)
> +{
[]
> 	if (ret) {
> +		pr_err("%s: Cannot attach to PHY (error: %d)\n",
> +				__func__, ret);

A lot of the message logging would be better using
more verbose forms like;

	netdev_<level>(dev, etc...)

[]

> +/* xgmac_config - entry point for changing configuration mode passed on by
> + * ifconfig
> + * @dev : pointer to the device structure
> + * @map : pointer to the device mapping structure
> + * Description:
> + * This function is a driver entry point which gets called by the kernel
> + * whenever some device configuration is changed.
> + * Return value:
> + * This function returns 0 if success and appropriate error otherwise.
> + */

It might be nicer if you used kernel-doc forms startig with
/**
for these comments everywhere.
