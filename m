From: Thomas Graf <tgraf@suug.ch>
Subject: Re: design for TSO performance fix
Date: Fri, 28 Jan 2005 02:57:51 +0100
Message-ID: <20050128015751.GT31837@postel.suug.ch>
References: <20050127163146.33b01e95.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050127163146.33b01e95.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050127163146.33b01e95.davem@davemloft.net> 2005-01-27 16:31
> The basic idea is that we stop trying to build TSO frames
> in the actual transmit queue.  Instead, TSO packets are
> built impromptu when we actually output packets on the
> transmit queue.

Sound great.

> static inline int tcp_skb_data_all_paged(struct sk_buff *skb)
> {
> 	return (skb->len == skb->data_len);
> }

You could also define this as (skb_headlen(skb) == 0)

> The logic is simple because if TSO is being done we know
> that all of the SKB data is paged (since SG+CSUM is a
> requirement for TSO).  The one case where that
> invariant might fail is due to a routing change (previous
> device cannot do SG+CSUM, new device has full TSO capability)
> and that is handled via the tcp_skb_data_all_paged() checks.

I assume the case when reroute changes oif to a device no
longer capable of SG+CSUM stays the same and the skb remains
paged until dev_queue_xmit?

> My thinking is that whatever added expensive this new scheme
> has, is offset by the simplifications the rest of the TCP
> stack will have since it will no longer need to know anything
> about multiple MSS values and packet counts.

I think the overhead is really worth the complexity that can
be removed with these changes.
