From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net] bonding: avoid defaulting hard_header_len to
 ETH_HLEN on slave removal
Date: Fri, 28 Apr 2017 16:04:33 -0400 (EDT)
Message-ID: <20170428.160433.78077372682012222.davem@davemloft.net>
References: <733d454d3c36e99b55de5374c7664364975b171d.1493313626.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <733d454d3c36e99b55de5374c7664364975b171d.1493313626.git.pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Thu, 27 Apr 2017 19:29:34 +0200

> On slave list updates, the bonding driver computes its hard_header_len
> as the maximum of all enslaved devices's hard_header_len.
> If the slave list is empty, e.g. on last enslaved device removal,
> ETH_HLEN is used.
> 
> Since the bonding header_ops are set only when the first enslaved
> device is attached, the above can lead to header_ops->create()
> being called with the wrong skb headroom in place.
> 
> If bond0 is configured on top of ipoib devices, with the
> following commands:
> 
> ifup bond0
> for slave in $BOND_SLAVES_LIST; do
> 	ip link set dev $slave nomaster
> done
> ping -c 1 <ip on bond0 subnet>
> 
> we will obtain a skb_under_panic() with a similar call trace:
 ...
> This change addresses the issue avoiding updating the bonding device
> hard_header_len when the slaves list become empty, forbidding to
> shrink it below the value used by header_ops->create().
> 
> The bug is there since commit 54ef31371407 ("[PATCH] bonding: Handle large
> hard_header_len") but the panic can be triggered only since
> commit fc791b633515 ("IB/ipoib: move back IB LL address into the hard
> header").
> 
> Reported-by: Norbert P <noe-PRwTpj6vllL463JZfw7VRw@public.gmane.org>
> Fixes: 54ef31371407 ("[PATCH] bonding: Handle large hard_header_len")
> Fixes: fc791b633515 ("IB/ipoib: move back IB LL address into the hard header")
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
