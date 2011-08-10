From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] pch ieee1588 driver for Intel EG20T PCH
Date: Wed, 10 Aug 2011 06:40:43 -0700
Message-ID: <1312983643.11924.84.camel@Joe-Laptop>
References: <1312956783-11460-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: richard.cochran@omicron.at, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qi.wang@intel.com,
	yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, tomoya-linux@dsn.okisemi.com
To: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1312956783-11460-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-08-10 at 15:13 +0900, Toshiharu Okada wrote:
> This patch is for IEEE1588 driver of Intel EG20T PCH.
> EG20T PCH is the platform controller hub that is used in Intel's
> general embedded platform.
> This driver adds support for using the EG20T PCH as a PTP clock.

> Would you review this patch, although this driver has not been tested yet?

Just trivia...

> diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
[]
> +/**
> + * struct ch_1588_params_ - 1588 module paramter

parameter

> + */
> +struct pch_params_ {
> +	u8 station[STATION_ADDR_LEN];
> +};
 
names for struct types ending in _ are pretty unusual.

[]

> +/**
> + * get_decimal() - Returns the decimal value of the passed hexadecimal value
> + * @ch:	The hexadecimal value that has to be converted.
> + */
> +static s32 get_decimal(u8 ch)
> +{
> +	s32 ret;
> +
> +	if ((ch >= '0') && (ch <= '9'))
> +		ret = ch - '0';
> +	else if ((ch >= 'A') && (ch <= 'F'))
> +		ret = 10 + ch - 'A';
> +	else if ((ch >= 'a') && (ch <= 'f'))
> +		ret = 10 + ch - 'a';
> +	else
> +		return -1;
> +
> +	return ret;
> +}

hex_to_bin

> +pch_probe(struct pci_dev *pdev, const struct pci_device_id *id)
[]
> +	if (ret != 0) {
> +		dev_err(&pdev->dev,
> +			"%s:could not enable the pci device\n", __func__);
> +		goto err_pci_en;
> +	}

It seems all of the dev_<level> logging messages include __func__.
I think these __func__ uses are not particularly valuable and could
be removed.

> +	/* retreive the available length of the IO memory space */

retrieve

> +	if (!request_mem_region(chip->mem_base, chip->mem_size, "1588_regs")) {
> +		dev_err(&pdev->dev, "%s: could not allocate register memory "
> +			"space\n", __func__);

Please don't split format strings.

		dev_err(&pdev->dev, "could not allocate register memory space\n");
or if you must
		dev_err(&pdev->dev, "%s: could not allocate register memory space\n",
			__func__);
[]
> +	if (strcmp(pch_param.station, "00:00:00:00:00:00") != 0) {
> +		if (pch_set_station_address(pch_param.station, pdev) != 0) {
> +			dev_err(&pdev->dev,
> +				"%s: Invalid station address parameter\n"
> +				"Module loaded; But, station address not set "
> +				"correctly\n", __func__);

			dev_err(&pdev->dev,
				"%s: Invalid station address parameter\n"
				"Module loaded but station address not set correctly\n",
				__func__);
