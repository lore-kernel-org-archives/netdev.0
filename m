From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net/phy: tune get_phy_c45_ids to support more c45
 phy
Date: Fri, 30 May 2014 17:41:14 -0700 (PDT)
Message-ID: <20140530.174114.2094570661893736648.davem@davemloft.net>
References: <1401267276-29648-1-git-send-email-Shengzhou.Liu@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shengzhou.Liu@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60880 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934753AbaEaAlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 20:41:16 -0400
In-Reply-To: <1401267276-29648-1-git-send-email-Shengzhou.Liu@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shengzhou Liu <Shengzhou.Liu@freescale.com>
Date: Wed, 28 May 2014 16:54:36 +0800

> -	/* Find first non-zero Devices In package.  Device
> -	 * zero is reserved, so don't probe it.
> -	 */
> +	/* Find first non-zero Devices In package */
>  	for (i = 1;
>  	     i < num_ids && c45_ids->devices_in_package == 0;
>  	     i++) {
 ...
> -			return 0;
> +			if (i) {

It makes no sense to test 'i' for zero vs. non-zero until the looping
construct it is contained within can actually hit a zero value.

It cannot currently, and adding such a check here makes the code
confusing.

I'm not applying this, sorry.
