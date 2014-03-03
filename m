From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 1/2] ethtool: Support for configurable RSS
 hash key
Date: Mon, 03 Mar 2014 15:19:46 -0500 (EST)
Message-ID: <20140303.151946.537238190479739067.davem@davemloft.net>
References: <1393589141-10597-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
	<0e1d7b54-dcbd-446d-b1c9-644086da138f@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: VenkatKumar.Duvvuru@Emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066AbaCCUTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 15:19:50 -0500
In-Reply-To: <0e1d7b54-dcbd-446d-b1c9-644086da138f@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Date: Fri, 28 Feb 2014 17:35:40 +0530

> + * @get_rxfh_key_size: Get the size of the RX flow hash key.
> + *	Returns zero if not supported for this specific device.
>   * @get_rxfh_indir_size: Get the size of the RX flow hash indirection table.
>   *	Returns zero if not supported for this specific device.
>   * @get_rxfh_indir: Get the contents of the RX flow hash indirection table.
>   *	Will not be called if @get_rxfh_indir_size returns zero.
> + * @get_rxfh: Get the contents of the RX flow hash indirection table and hash
> + *	key.
> + *	Will not be called if @get_rxfh_indir_size and @get_rxfh_key_size
> + *	returns zero.
>   *	Returns a negative error code or zero.
>   * @set_rxfh_indir: Set the contents of the RX flow hash indirection table.
>   *	Will not be called if @get_rxfh_indir_size returns zero.
> + * @set_rxfh: Set the contents of the RX flow hash indirection table and
> + *	hash key.
> + *	Will not be called if @get_rxfh_indir_size and @get_rxfh_key_size
> + *	returns zero.
 ...
> +	if (!(dev->ethtool_ops->get_rxfh_indir_size ||
> +	      dev->ethtool_ops->get_rxfh_key_size ||
> +	      dev->ethtool_ops->get_rxfh))
> +		return -EOPNOTSUPP;

This may be just my taste but I prefer it if all the operations have to
be non-NULL to support the new feature.  The code is so much easier to
validate that way.

Even if you have to make generic "ethtool_get_rxfh_indir_size_zero"
etc. routines that implementations hook up if they don't support the
particular aspect, I prefer that to "NULL means this".

Could you make this change and resubmit?
