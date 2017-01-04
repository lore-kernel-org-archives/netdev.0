From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH repost net-next] dsa: mv88e6xxx: Optimise atu_get
Date: Wed, 04 Jan 2017 16:11:03 -0500 (EST)
Message-ID: <20170104.161103.175830630875484681.davem@davemloft.net>
References: <1483556184-4176-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: volodymyr.bendiuga@gmail.com, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35428 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031288AbdADVLP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 16:11:15 -0500
In-Reply-To: <1483556184-4176-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed,  4 Jan 2017 19:56:24 +0100

> +static inline u64 ether_addr_to_u64(const u8 *addr)
> +{
> +	u64 u = 0;
> +	int i;
> +
> +	for (i = 0; i < ETH_ALEN; i++)
> +		u = u << 8 | addr[i];
> +
> +	return u;
> +}
 ...
> +static inline void u64_to_ether_addr(u64 u, u8 *addr)
> +{
> +	int i;
> +
> +	for (i = ETH_ALEN - 1; i >= 0; i--) {
> +		addr[i] = u & 0xff;
> +		u = u >> 8;
> +	}
> +}

I think these two routines behave differently on big vs little
endian.  And I doubt this was your intention.
