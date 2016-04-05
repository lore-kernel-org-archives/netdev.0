From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 03/16] fm10k: Avoid crashing the kernel
Date: Tue, 05 Apr 2016 12:12:34 -0400 (EDT)
Message-ID: <20160405.121234.207383895896842448.davem@davemloft.net>
References: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1459843288-40623-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bruce.w.allan@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59478 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758327AbcDEQMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 12:12:43 -0400
In-Reply-To: <1459843288-40623-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  5 Apr 2016 01:01:15 -0700

> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
> index 28837ae..6a9f988 100644
> --- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
> @@ -398,7 +398,7 @@ static void fm10k_get_reg_q(struct fm10k_hw *hw, u32 *buff, int i)
>  	buff[idx++] = fm10k_read_reg(hw, FM10K_TX_SGLORT(i));
>  	buff[idx++] = fm10k_read_reg(hw, FM10K_PFVTCTL(i));
>  
> -	BUG_ON(idx != FM10K_REGS_LEN_Q);
> +	BUILD_BUG_ON(idx != FM10K_REGS_LEN_Q);
>  }
>  
>  /* If function above adds more registers this define needs to be updated */

As Joe suggested, it is not reasonable to expect all compilers to be able to figure
out the result of all of the index increments in this function lead to a specific
constant value.

Your only option is to either keep the code as-is, or add proper error reporting to
this function and to all callers, in order to handle the situation at run time which
I realize is exactly what you are trying to avoid.

If this crashes at run time with the BUG_ON(), it's going to happen really quickly
when you bring the interface up.  So I don't see the run time check as so tragic.
