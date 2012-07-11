From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] etherdevice: introduce eth_broadcast_addr
Date: Tue, 10 Jul 2012 20:09:44 -0400
Message-ID: <CAP=VYLqNyAF1gSsKTd3YojeJXK_-pEzXAKyVQbQfwhtwOyMmwg@mail.gmail.com>
References: <1341310587.5131.2.camel@jlt3.sipsolutions.net>
 <20120708.235808.1602900783296556684.davem@davemloft.net> <1341937124.4475.27.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:52788 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069Ab2GKAKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 20:10:17 -0400
In-Reply-To: <1341937124.4475.27.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 10, 2012 at 12:18 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> From: Johannes Berg <johannes.berg@intel.com>
>
> A lot of code has either the memset or an inefficient copy
> from a static array that contains the all-ones broadcast

Shouldn't we see all that "lot of code" here in this same
commit, now using this new shortcut?  If we apply this, we
have a new function, but with no users.  If you have done
the audit, and found the inefficient cases, why isn't it here?

I would think it better to just fix those people who have a
pointless static array of all-ones to use the memset.  If it was a
multi line thing to achieve the eth_broadcast_addr() then it
might make sense to exist.  But as a one line alias, it does
seem somewhat pointless to me.

Paul.
--

> address. Introduce eth_broadcast_addr() to fill an address
> with all ones, making the code clearer and allowing us to
> get rid of some constant arrays.
>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
>  include/linux/etherdevice.h |   11 +++++++++++
>  1 file changed, 11 insertions(+)
>
> diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
> index 3d406e0..98a27cc 100644
> --- a/include/linux/etherdevice.h
> +++ b/include/linux/etherdevice.h
> @@ -138,6 +138,17 @@ static inline void random_ether_addr(u8 *addr)
>  }
>
>  /**
> + * eth_broadcast_addr - Assign broadcast address
> + * @addr: Pointer to a six-byte array containing the Ethernet address
> + *
> + * Assign the broadcast address to the given address array.
> + */
> +static inline void eth_broadcast_addr(u8 *addr)
> +{
> +       memset(addr, 0xff, ETH_ALEN);
> +}
> +
> +/**
>   * eth_hw_addr_random - Generate software assigned random Ethernet and
>   * set device flag
>   * @dev: pointer to net_device structure
> --
> 1.7.10.4
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
