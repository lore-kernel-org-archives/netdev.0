From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] batadv: Slight optimization of batadv_compare_eth
Date: Fri, 06 Dec 2013 15:39:44 -0500 (EST)
Message-ID: <20131206.153944.1382127535160341376.davem@davemloft.net>
References: <1386317890.31845.26.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mareklindner@neomailbox.ch, sw@simonwunderlich.de,
	antonio@meshcoding.com, b.a.t.m.a.n@lists.open-mesh.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386317890.31845.26.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Fri, 06 Dec 2013 00:18:10 -0800

> @@ -266,7 +266,11 @@ static inline void batadv_dbg(int type __always_unused,
>   */
>  static inline int batadv_compare_eth(const void *data1, const void *data2)
>  {
> -	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
> +#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
> +	return ether_addr_equal(data1, data2);
> +#else
> +	return memcmp(data1, data2, ETH_ALEN) == 0;
> +#endif
>  }

Let's not crap up implementations with these ifdefs.

What's the specific situation here?  Is it that 'data1' and/or
'data2' my not be u16 aligned?

If so, make a function for that in linux/etherdevice.h and invoke it
in such places.  You can name it something like
"ether_addr_equal_unaligned()" or similar.

Thanks.
