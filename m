From: Robert MARKLUND <robert.marklund@stericsson.com>
Subject: RE: [PATCH] smsc911x: Add regulator support
Date: Mon, 17 Oct 2011 13:30:06 +0200
Message-ID: <2B1D156D95AE9B4EAD379CB9E465FE7324AB09DE76@EXDCVYMBSTM005.EQ1STM.local>
References: <1318834597-3479-1-git-send-email-robert.marklund@stericsson.com>
 <20111017105256.GG5448@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:34412 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752058Ab1JQLaV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 07:30:21 -0400
In-Reply-To: <20111017105256.GG5448@sirena.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Mark Brown [mailto:broonie@opensource.wolfsonmicro.com]
> Sent: den 17 oktober 2011 12:53
> To: Robert MARKLUND
> Cc: netdev@vger.kernel.org; Steve Glendinning; Mathieu Poirer
> Subject: Re: [PATCH] smsc911x: Add regulator support
> 
> On Mon, Oct 17, 2011 at 08:56:37AM +0200, Robert Marklund wrote:
> 
> > +	/* Request regulator for vddvario */
> > +	if (request && !pdata->regulator_vddvario) {
> > +		pdata->regulator_vddvario = regulator_get(&pdev-
> >dev,
> > +				"vddvario");
> > +		if (IS_ERR(pdata->regulator_vddvario)) {
> > +			netdev_warn(ndev,
> > +					"%s: Failed to
> get regulator '%s'\n",
> > +					__func__,
> "vddvario");
> > +			pdata->regulator_vddvario = NULL;
> > +		}
> 
> No, this is broken - look at how other devices use the regulator API.
> The driver should just request and use the regulators unconditionally
> and let the stubbing and mapping facilities the API has deal with
> ensuring that they always succeed.

[Robert MARKLUND] 
So what you mean is get them and use them and ignore all the return codes, and let the FW take care of the error handling ?

> 
> As a side note the use of "pdata" as a name for the driver internal
> data
> is really not helpful, pdata is traditionally the platform data passed
> in by the machine (which would be even more broken).

[Robert MARKLUND] 
In the driver they have used this name for this structure throughout the file I just followed that.
Personally I think it will be more confusing to change the name of this structure in just this new function.

/R
