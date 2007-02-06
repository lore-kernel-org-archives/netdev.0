From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 5/7] sky2: Yukon Extreme support
Date: Tue, 6 Feb 2007 22:52:56 +0100
Message-ID: <20070206215256.GA28967@electric-eye.fr.zoreil.com>
References: <20070206184538.675048000@linux-foundation.org> <20070206184855.246345000@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:55552 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965544AbXBFVyx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 16:54:53 -0500
Content-Disposition: inline
In-Reply-To: <20070206184855.246345000@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> :
[...]
> @@ -289,8 +289,10 @@
>  	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
>  	u16 ctrl, ct1000, adv, pg, ledctrl, ledover, reg;
>  
> -	if (sky2->autoneg == AUTONEG_ENABLE &&
> -	    !(hw->chip_id == CHIP_ID_YUKON_XL || hw->chip_id == CHIP_ID_YUKON_EC_U)) {
> +	if (sky2->autoneg == AUTONEG_ENABLE
> +	    && !(hw->chip_id == CHIP_ID_YUKON_XL
> +		 || hw->chip_id == CHIP_ID_YUKON_EC_U
> +		 || hw->chip_id == CHIP_ID_YUKON_EX)) {
[...]
> +			if (sky2->autoneg == AUTONEG_ENABLE
> +			    && (hw->chip_id == CHIP_ID_YUKON_XL
> +				|| hw->chip_id == CHIP_ID_YUKON_EC_U
> +				|| hw->chip_id == CHIP_ID_YUKON_EX)) {
[...]
> +	if (hw->chip_id == CHIP_ID_YUKON_XL
> +	    || hw->chip_id == CHIP_ID_YUKON_EC_U
> +	    || hw->chip_id == CHIP_ID_YUKON_EX) {
[...]
> +	if (hw->chip_id == CHIP_ID_YUKON_XL
> +	    || hw->chip_id == CHIP_ID_YUKON_EC_U
> +	    || hw->chip_id == CHIP_ID_YUKON_EX)

Any objection against the use of :

static bool is_yukon_extreme(struct sky2_hw *hw)
{
	return hw->chip_id == CHIP_ID_YUKON_XL ||
		hw->chip_id == CHIP_ID_YUKON_EC_U ||
		hw->chip_id == CHIP_ID_YUKON_EX;
}

?

-- 
Ueimor
