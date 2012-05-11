From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/2] igb: Add Support for new i210/i211 devices.
Date: Fri, 11 May 2012 18:27:35 -0400 (EDT)
Message-ID: <20120511.182735.63933163877487008.davem@davemloft.net>
References: <1336723282-3130-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1336723282-3130-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: carolyn.wyborny@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932266Ab2EKW1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 18:27:45 -0400
In-Reply-To: <1336723282-3130-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 11 May 2012 01:01:22 -0700

> +s32 igb_acquire_nvm_i210(struct e1000_hw *hw)
> +{
> +	s32 ret_val;
> +
> +	ret_val = igb_acquire_swfw_sync_i210(hw, E1000_SWFW_EEP_SM);
> +
> +	return ret_val;
> +}

Please, this is just unnecessary syntactic masterbation, simplify this
to:

s32 igb_acquire_nvm_i210(struct e1000_hw *hw)
{
	return igb_acquire_swfw_sync_i210(hw, E1000_SWFW_EEP_SM);
}

And:

> +void igb_release_nvm_i210(struct e1000_hw *hw)
> +{
> +
> +	igb_release_swfw_sync_i210(hw, E1000_SWFW_EEP_SM);
> +}

Please get rid of that unnecessary empty line.

I can really tell when someone is extremely careless when removing
their debugging code, and I can almost guarentee that's what has
happened here.
