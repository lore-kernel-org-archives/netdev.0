From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: set transport header earlier
Date: Tue, 16 Jul 2013 13:00:08 -0700 (PDT)
Message-ID: <20130716.130008.1606475609280013646.davem@davemloft.net>
References: <1373943799.10804.96.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com,
	netfilter-devel@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1373943799.10804.96.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 15 Jul 2013 20:03:19 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 45f00f99d6e ("ipv4: tcp: clean up tcp_v4_early_demux()") added a
> performance regression for non GRO traffic, basically disabling
> IP early demux.
> 
> IPv6 stack resets transport header in ip6_rcv() before calling
> IP early demux in ip6_rcv_finish(), while IPv4 does this only in
> ip_local_deliver_finish(), _after_ IP early demux.
> 
> GRO traffic happened to enable IP early demux because transport header
> is also set in inet_gro_receive()
> 
> Instead of reverting the faulty commit, we can make IPv4/IPv6 behave the
> same : transport_header should be set in ip_rcv() instead of
> ip_local_deliver_finish()
> 
> ip_local_deliver_finish() can also use skb_network_header_len() which is
> faster than ip_hdrlen()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
