From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] tcp: make sysctl_tcp_ecn namespace aware
Date: Sat, 5 Jan 2013 20:05:08 +0100
Message-ID: <20130105190508.GE4031@order.stressinduktion.org>
References: <20130105150130.GC4031@order.stressinduktion.org> <20130105110005.2bf230eb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, davem@davemloft.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37932 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755833Ab3AETFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 14:05:09 -0500
Content-Disposition: inline
In-Reply-To: <20130105110005.2bf230eb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 05, 2013 at 11:00:05AM -0800, Stephen Hemminger wrote:
> Rather than passing sysctl_tcp_ecn around as a parameter, I think it
> would be clearer and more efficient to make the ECN functions namespace
> aware.
> 
> Instead of:
> > @@ -728,7 +728,8 @@ struct tcp_skb_cb {
> >   * notifications, we disable TCP ECN negociation.
> >   */
> >  static inline void
> > -TCP_ECN_create_request(struct request_sock *req, const struct sk_buff *skb)
> > +TCP_ECN_create_request(struct request_sock *req, const struct sk_buff *skb,
> > +		int sysctl_tcp_ecn)
> >  {
> >  	const struct tcphdr *th = tcp_hdr(skb);
> >  
> 
> @@ -731,8 +730,9 @@ static inline void
>  TCP_ECN_create_request(struct request_sock *req, const struct sk_buff *skb)
>  {
>         const struct tcphdr *th = tcp_hdr(skb);
> -
> -       if (sysctl_tcp_ecn && th->ece && th->cwr &&
> +       
> +       if (sock_net(req->sk)->ipv4.sysctl_tcp_ecn && 
> +           th->ece && th->cwr &&
>             INET_ECN_is_not_ect(TCP_SKB_CB(skb)->ip_dsfield))
>                 inet_rsk(req)->ecn_ok = 1;

Having a quick look, I think req->sk is not initialized at that moment, but
I'll verify later.

Thanks!
