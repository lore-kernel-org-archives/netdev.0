From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 09/14] e1000e: fix possible buffer overflow
Date: Fri, 21 Nov 2008 16:57:00 -0800 (PST)
Message-ID: <20081121.165700.138867321.davem@davemloft.net>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
	<20081121190128.32313.90707.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46654
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754046AbYKVA5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:57:01 -0500
In-Reply-To: <20081121190128.32313.90707.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 21 Nov 2008 11:01:28 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Put in missing bounds checking of an array.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

No magic constants, please.  What does the "+ 5" mean?

And using a macro that is:

1) Used in exactly one place
2) Gives no more information than the expanded ARRAY_SIZE()

is pretty useless as well.

Patch not applied.

> @@ -721,6 +723,9 @@ static s32 e1000_get_cable_length_80003es2lan(struct e1000_hw *hw)
>  		return ret_val;
>  
>  	index = phy_data & GG82563_DSPD_CABLE_LENGTH;
> +	if (index >= GG82563_CABLE_LENGTH_TABLE_SIZE + 5)
> +		return E1000_ERR_PHY;
> +
>  	phy->min_cable_length = e1000_gg82563_cable_length_table[index];
>  	phy->max_cable_length = e1000_gg82563_cable_length_table[index+5];
>  
