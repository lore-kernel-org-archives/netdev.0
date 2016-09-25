From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: xt_socket: fix transparent match for IPv6
 request sockets
Date: Sun, 25 Sep 2016 13:47:29 +0200
Message-ID: <20160925114729.GA8645@salvia>
References: <20160923092742.88262-1-hidden@balabit.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        Alex Badics <alex.badics@balabit.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: KOVACS Krisztian <hidden@balabit.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160923092742.88262-1-hidden@balabit.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 23, 2016 at 11:27:42AM +0200, KOVACS Krisztian wrote:
> The introduction of TCP_NEW_SYN_RECV state, and the addition of request
> sockets to the ehash table seems to have broken the --transparent option
> of the socket match for IPv6 (around commit a9407000).
> 
> Now that the socket lookup finds the TCP_NEW_SYN_RECV socket instead of the
> listener, the --transparent option tries to match on the no_srccheck flag
> of the request socket.
> 
> Unfortunately, that flag was only set for IPv4 sockets in tcp_v4_init_req()
> by copying the transparent flag of the listener socket. This effectively
> causes '-m socket --transparent' not match on the ACK packet sent by the
> client in a TCP handshake.
> 
> Based on the suggestion from Eric Dumazet, this change moves the code
> initializing no_srccheck to tcp_conn_request(), rendering the above
> scenario working again.

Applied, thanks Krisztian.
