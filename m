From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: updates to syncookies - timestamps not needed any more (freebsd)
Date: Fri, 26 Jul 2013 08:45:44 +0200
Message-ID: <20130726064544.GC24247@order.stressinduktion.org>
References: <20130708160421.GA9763@order.stressinduktion.org> <20130711.165726.2168148122875413191.davem@davemloft.net> <20130712084145.GJ27468@breakpoint.cc> <1373637885.10804.7.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:40504 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910Ab3GZGpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 02:45:46 -0400
Content-Disposition: inline
In-Reply-To: <1373637885.10804.7.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric!

On Fri, Jul 12, 2013 at 07:04:45AM -0700, Eric Dumazet wrote:
> BTW, following patch allows to test more easily syncookies behavior.
> 
> If sysctl_tcp_syncookies is set to 2, we always use syncookies.
> 
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 35675e4..590659e 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1462,7 +1462,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
>  	 * limitations, they conserve resources and peer is
>  	 * evidently real one.
>  	 */
> -	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
> +	if ((sysctl_tcp_syncookies == 2 ||
> +	     inet_csk_reqsk_queue_is_full(sk)) && !isn) {
>  		want_cookie = tcp_syn_flood_action(sk, skb, "TCP");
>  		if (!want_cookie)
>  			goto drop;
> 

While cleaning up my patch directory I found this snippet. Perhaps you
could send it for inclusion for net-next? Three nice additions: a similar
change in tcp_ipv6.c and perhaps get rid of the warning messages printed
to the console in case of syncookies == 2? A small update to ip-sysctl.txt
wouldn't hurt either.

If you want to, I can take it and refresh it.

Thanks,

  Hannes
