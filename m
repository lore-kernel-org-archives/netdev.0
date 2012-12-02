From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net] tcp: fix crashes in do_tcp_sendpages()
Date: Sat, 01 Dec 2012 17:43:02 -0800
Message-ID: <1354412582.19578.3.camel@joe-AO722>
References: <20121115222812.GA647@1wt.eu>
	 <1353023344.10798.8.camel@edumazet-glaptop> <20121201194304.GI25450@1wt.eu>
	 <20121201205227.GA28390@1wt.eu>
	 <1354398458.20109.528.camel@edumazet-glaptop>
	 <1354401121.20109.531.camel@edumazet-glaptop>
	 <20121201224044.GL25450@1wt.eu>
	 <1354403222.20109.539.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36468 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751611Ab2LBBnE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2012 20:43:04 -0500
In-Reply-To: <1354403222.20109.539.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-12-01 at 15:07 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Recent network changes allowed high order pages being used
> for skb fragments.
> 
> This uncovered a bug in do_tcp_sendpages() which was assuming its caller
> provided an array of order-0 page pointers.
> 
> We only have to deal with a single page in this function, and its order
> is irrelevant.
[]
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
[]
> @@ -830,8 +830,8 @@ static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
>  	return mss_now;
>  }
>  
> -static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
> -			 size_t psize, int flags)
> +static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
> +				size_t size, int flags)

Shouldn't this now be named do_tcp_sendpage ?
