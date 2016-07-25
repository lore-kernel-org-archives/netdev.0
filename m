From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 4/4] be2net: replace polling with sleeping in
 the FW completion path
Date: Mon, 25 Jul 2016 10:51:30 -0700 (PDT)
Message-ID: <20160725.105130.1337790235000032163.davem@davemloft.net>
References: <1469184946-26309-1-git-send-email-sathya.perla@broadcom.com>
	<1469184946-26309-5-git-send-email-sathya.perla@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43172 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752805AbcGYRvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 13:51:31 -0400
In-Reply-To: <1469184946-26309-5-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@broadcom.com>
Date: Fri, 22 Jul 2016 06:55:46 -0400

> @@ -4477,6 +4551,22 @@ static int be_if_create(struct be_adapter *adapter)
>  	u32 cap_flags = be_if_cap_flags(adapter);
>  	int status;
>  
> +	/* alloc required memory for other filtering fields */
> +	adapter->pmac_id = kcalloc(be_max_uc(adapter),
> +				   sizeof(*adapter->pmac_id), GFP_KERNEL);
> +	if (!adapter->pmac_id)
> +		return -ENOMEM;
> +
> +	adapter->mc_list = kcalloc(be_max_mc(adapter),
> +				   sizeof(*adapter->mc_list), GFP_KERNEL);
> +	if (!adapter->mc_list)
> +		return -ENOMEM;
> +
> +	adapter->uc_list = kcalloc(be_max_uc(adapter),
> +				   sizeof(*adapter->uc_list), GFP_KERNEL);
> +	if (!adapter->uc_list)
> +		return -ENOMEM;

These error paths are leaking memory, please audit this in the rest of your
change as well.
