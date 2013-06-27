From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v1 2/3] pch_gbe: convert pr_* to netdev_*
Date: Wed, 26 Jun 2013 17:59:30 -0700
Message-ID: <1372294770.2172.22.camel@joe-AO722>
References: <1372263217-1938-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <1372263217-1938-3-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Darren Hart <dvhart@linux.intel.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:60142 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751557Ab3F0A7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 20:59:32 -0400
In-Reply-To: <1372263217-1938-3-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-26 at 19:13 +0300, Andy Shevchenko wrote:
> We may use nice macros to prefix our messages with proper device name.
[]
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
[]
> @@ -131,10 +133,12 @@ s32 pch_gbe_phy_get_id(struct pch_gbe_hw *hw)
>   */
>  s32 pch_gbe_phy_read_reg_miic(struct pch_gbe_hw *hw, u32 offset, u16 *data)
>  {
> +	struct pch_gbe_adapter *adapter = pch_gbe_hw_to_adapter(hw);
>  	struct pch_gbe_phy_info *phy = &hw->phy;
>  
>  	if (offset > PHY_MAX_REG_ADDRESS) {
> -		pr_err("PHY Address %d is out of range\n", offset);
> +		netdev_err(adapter->netdev, "PHY Address %d is out of range\n",
> +			   offset);

For all the patch blocks in this set, I suggest taking
these reverences only when necessary.

Assigning them at the beginning of the function seems
wasteful when these may not be used at all.
