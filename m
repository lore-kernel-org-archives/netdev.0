From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH 2/2] net/smsc911x: Add regulator support
Date: Wed, 26 Oct 2011 10:38:39 +0200
Message-ID: <20111026083838.GA9157@opensource.wolfsonmicro.com>
References: <1319616356-6391-1-git-send-email-linus.walleij@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>,
	Robert Marklund <robert.marklund@stericsson.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Linus Walleij <linus.walleij@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:36928 "EHLO
	opensource.wolfsonmicro.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753174Ab1JZIim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 04:38:42 -0400
Content-Disposition: inline
In-Reply-To: <1319616356-6391-1-git-send-email-linus.walleij@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2011 at 10:05:56AM +0200, Linus Walleij wrote:

> +	/* enable/disable regulator for vddvario */
> +	if (pdata->regulator_vddvario) {

This has the same issue as last time - if you've got conditional code
like this in the body of the driver something is going wrong.  Unless
the supply is genuinely optional and might not be physically present on
some systems the driver should fail if it can't get it.  The regulator
API will stub itself out when not in use.
