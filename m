From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: cpsw: ignore VLAN ID 1
Date: Tue, 06 Jan 2015 14:13:23 -0500 (EST)
Message-ID: <20150106.141323.2091288413667564444.davem@davemloft.net>
References: <1420566212-30081-1-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	stable@vger.kernel.org, mugunthanvnm@ti.com
To: balbi@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53035 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756407AbbAFTOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 14:14:24 -0500
In-Reply-To: <1420566212-30081-1-git-send-email-balbi@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felipe Balbi <balbi@ti.com>
Date: Tue, 6 Jan 2015 11:43:32 -0600

> CPSW completely hangs if we add, and later remove,
> VLAN ID #1. What happens is that after removing
> VLAN ID #1, no packets will be received by CPSW
> rendering network unusable.
> 
> In order to "fix" the issue, we're returning -EINVAL
> if anybody tries to add VLAN ID #1. While at that,
> also filter out any ID > 4095 because we only have
> 12 bits for VLAN IDs.
> 
> Fixes: 3b72c2f (drivers: net:ethernet: cpsw: add support for VLAN)
> Cc: <stable@vger.kernel.org> # v3.9+
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> Tested-by: Schuyler Patton <spatton@ti.com>
> Signed-off-by: Felipe Balbi <balbi@ti.com>

You can't just unilaterally make one VLAN ID unusable.

A better way to handle this situation must be found,
and if that means turning off hw VLAN support completely,
that's a much better alternative to this.

I'm not applying this patch, sorry.
