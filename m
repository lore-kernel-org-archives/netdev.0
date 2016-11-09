From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 1/2] net: mvpp2: don't bring up on MAC address set
Date: Wed, 9 Nov 2016 14:22:11 +0100
Message-ID: <20161109142211.28caffda@free-electrons.com>
References: <ff17831771f3575f351c134703d3f153485b01c0.1478696194.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Marcin Wojtas <mw@semihalf.com>, netdev@vger.kernel.org,
        Gregory Clement <gregory.clement@free-electrons.com>
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:42247 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752395AbcKINcG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 08:32:06 -0500
In-Reply-To: <ff17831771f3575f351c134703d3f153485b01c0.1478696194.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed,  9 Nov 2016 14:56:33 +0200, Baruch Siach wrote:
> Current .ndo_set_mac_address implementation brings up the interface when revert
> to original address after failure succeeds. Fix this.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>

Indeed, this piece of code is not very smart.

> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> index 60227a3452a4..e427b4706726 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
> @@ -5686,9 +5686,8 @@ static int mvpp2_set_mac_address(struct net_device *dev, void *p)
>  		if (!err)
>  			return 0;
>  		/* Reconfigure parser to accept the original MAC address */
> -		err = mvpp2_prs_update_mac_da(dev, dev->dev_addr);
> -		if (err)
> -			goto error;
> +		mvpp2_prs_update_mac_da(dev, dev->dev_addr);
> +		goto error;

Wouldn't it make more sense to call mvpp2_prs_update_mac_da() under
the error: goto label?

But if you think beyond that, it is a bit crazy that to handle the
error case of mvpp2_prs_update_mac_da(), we have to call
mvpp2_prs_update_mac_da(), which is exactly the same function...

Perhaps it would be interesting to investigate what are the various
conditions for which mvpp2_prs_update_mac_da() fails, and see if we can
avoid them.

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
