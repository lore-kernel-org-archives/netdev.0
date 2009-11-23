From: Joe Perches <joe@perches.com>
Subject: Re: Diagnostic Monitoring Interface Monitoring (DOM) PATCH 4/5 for
 net-next-2.6
Date: Mon, 23 Nov 2009 15:07:39 -0800
Message-ID: <1259017659.16503.138.camel@Joe-Laptop.home>
References: <19211.4849.284727.703717@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Robert Olsson <robert@herjulf.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1104 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754563AbZKWXHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 18:07:34 -0500
In-Reply-To: <19211.4849.284727.703717@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-11-23 at 23:55 +0100, Robert Olsson wrote:
> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Can you run ./scripts/checkpatch.pl on your patches please?

> +	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_SLOPE, &pd->temp_slope)))
> +		goto out;
[etc...]
> +	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_I_OFFSET, &pd->tx_bias_offset)))
> +		goto out;

perhaps this is clearer as:

	if (read_phy_diag(hw, 0x1, reg, loc) ||
	    read_phy_diag(hw, 0x1, reg2, loc2) ||
	...
	    read_phy_diag(hw, 0x1, regN, locN))
		goto out;


