From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 19/19] e1000: major part of the new API changes
Date: Fri, 30 Mar 2007 13:19:37 -0700
Message-ID: <460D70D9.5020704@linux-foundation.org>
References: <20070329163304.6595.81963.stgit@localhost.localdomain> <20070329164038.6595.18817.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, bruce.w.allan@intel.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	cramerj@intel.com, john.ronciak@intel.com,
	arjan.van.de.ven@intel.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:50863 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753549AbXC3UTr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 16:19:47 -0400
In-Reply-To: <20070329164038.6595.18817.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>  
> +s32
> +e1000_alloc_zeroed_dev_spec_struct(struct e1000_hw *hw, u32 size)
> +{
> +	hw->dev_spec = kmalloc(size, GFP_KERNEL);
> +
> +	if (!hw->dev_spec)
> +		return -ENOMEM;
> +
> +	memset(hw->dev_spec, 0, size);
> +
> +	return E1000_SUCCESS;
> +}
>   

This is what is wrong with a lot of the new code. It is written as
verbose as possible.

What is wrong with open coded
    hw->dev_spec = kzalloc(size, GFP_KERNEL).
> +
> +void
> +e1000_free_dev_spec_struct(struct e1000_hw *hw)
> +{
> +	if (!hw->dev_spec)
> +		return;
> +
> +	kfree(hw->dev_spec);
> +}
> +
>   
Almost looks like you contracted this out to someone paid by the LOC.


