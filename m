From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/3] net/ip_tunnels: Introduce
 tunnel_id_to_key32() and key32_to_tunnel_id()
Date: Mon, 22 Aug 2016 19:00:27 +0200
Message-ID: <20160822190027.6b4e6028@griffin>
References: <20160822143834.32422-1-amir@vadai.me>
        <20160822143834.32422-2-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48760 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753732AbcHVRAe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 13:00:34 -0400
In-Reply-To: <20160822143834.32422-2-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While cleaning this up, you may as well take the best of both
implementations.

On Mon, 22 Aug 2016 17:38:32 +0300, Amir Vadai wrote:
> +static inline __be64 key32_to_tunnel_id(__be32 key)
> +{
> +#ifdef __BIG_ENDIAN
> +	return (__force __be64)((__force u32)key);

The inner cast seems to be superfluous?

> +#else
> +	return (__force __be64)((__force u64)key << 32);
> +#endif
> +}
> +
> +/* Returns the least-significant 32 bits of a __be64. */
> +static inline __be32 tunnel_id_to_key32(__be64 x)

Please use a more descriptive name than "x". "tunnel_id" or "tun_id"
seems to be more appropriate.

> +{
> +#ifdef __BIG_ENDIAN
> +	return (__force __be32)x;
> +#else
> +	return (__force __be32)((__force u64)x >> 32);
> +#endif
> +}

Looks good otherwise.

Thanks,

 Jiri
