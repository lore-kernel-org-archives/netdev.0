From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH] smsc911x: Add regulator support
Date: Mon, 17 Oct 2011 11:52:56 +0100
Message-ID: <20111017105256.GG5448@sirena.org.uk>
References: <1318834597-3479-1-git-send-email-robert.marklund@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>
To: Robert Marklund <robert.marklund@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:50258 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850Ab1JQKw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 06:52:59 -0400
Content-Disposition: inline
In-Reply-To: <1318834597-3479-1-git-send-email-robert.marklund@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2011 at 08:56:37AM +0200, Robert Marklund wrote:

> +	/* Request regulator for vddvario */
> +	if (request && !pdata->regulator_vddvario) {
> +		pdata->regulator_vddvario = regulator_get(&pdev->dev,
> +				"vddvario");
> +		if (IS_ERR(pdata->regulator_vddvario)) {
> +			netdev_warn(ndev,
> +					"%s: Failed to get regulator '%s'\n",
> +					__func__, "vddvario");
> +			pdata->regulator_vddvario = NULL;
> +		}

No, this is broken - look at how other devices use the regulator API.
The driver should just request and use the regulators unconditionally
and let the stubbing and mapping facilities the API has deal with
ensuring that they always succeed.

As a side note the use of "pdata" as a name for the driver internal data
is really not helpful, pdata is traditionally the platform data passed
in by the machine (which would be even more broken).
