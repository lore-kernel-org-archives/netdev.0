From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.24] pasemi_mac: Fix reuse of free'd skb
Date: Tue, 04 Dec 2007 14:54:44 -0500
Message-ID: <4755B084.4070501@pobox.com>
References: <20071204033414.GA13616@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	dwmw2@infradead.org, ranger@gentoo.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47999 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752549AbXLDTyv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 14:54:51 -0500
In-Reply-To: <20071204033414.GA13616@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olof Johansson wrote:
> Turns out we're freeing the skb when we detect CRC error, but we're
> not clearing out info->skb. We could either clear it and have the stack
> reallocate it, or just leave it and the rx ring refill code will reuse
> the one that was allocated.
> 
> Reusing a freed skb obviously caused some nasty crashes of various kind,
> as reported by Brent Baude and David Woodhouse.
> 
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>
> 
> ---
> 
> Jeff, I'd like to see this in 2.6.24, it's causing some real problems
> out there. It's not needed in the 2.6.25 queue since the other changes
> there have already covered these cases.
> 
> My test network at home is quiet enough to not cause CRC errors, we
> mainly get those during interface bringup before speed is configured.
> 
> diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
> index 09b4fde..6617e24 100644
> --- a/drivers/net/pasemi_mac.c
> +++ b/drivers/net/pasemi_mac.c
> @@ -586,7 +586,7 @@ static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
>  			/* CRC error flagged */
>  			mac->netdev->stats.rx_errors++;
>  			mac->netdev->stats.rx_crc_errors++;
> -			dev_kfree_skb_irq(skb);
> +			/* No need to free skb, it'll be reused */
>  			goto next;

applied #upstream-fixes


