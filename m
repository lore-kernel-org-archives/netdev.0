From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] asix: asix_rx_fixup surgery to reduce skb
 truesizes
Date: Fri, 16 Mar 2012 01:52:30 -0700 (PDT)
Message-ID: <20120316.015230.503523246344631871.davem@davemloft.net>
References: <1331792312.2543.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, aurel-U/apLSaFET4dnm+yROfE0A@public.gmane.org, trond-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
	grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1331792312.2543.16.camel@edumazet-laptop>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 14 Mar 2012 23:18:32 -0700

> asix_rx_fixup() is complex, and does some unnecessary memory copies (at
> least on x86 where NET_IP_ALIGN is 0)
> 
> Also, it tends to provide skbs with a big truesize (4096+256 with
> MTU=1500) to upper stack, so incoming trafic consume a lot of memory and
> I noticed early packet drops because we hit socket rcvbuf too fast.
> 
> Switch to a different strategy, using copybreak so that we provide nice
> skbs to upper stack (including the NET_SKB_PAD to avoid future head
> reallocations in some paths)
> 
> With this patch, I no longer see packets drops or tcp collapses on
> various tcp workload with a AX88772 adapter.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
