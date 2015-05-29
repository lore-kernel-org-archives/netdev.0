From: Willy Tarreau <w@1wt.eu>
Subject: Re: Fw: [Bug 99161] New: 2.6.32.66 PPC Oops in tcp_send_fin
Date: Fri, 29 May 2015 17:59:13 +0200
Message-ID: <20150529155912.GA2669@1wt.eu>
References: <20150529081200.7cf08fd6@urahara> <1432914731.7456.91.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, varenet@parisc-linux.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:49016 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754889AbbE2P7W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 11:59:22 -0400
Content-Disposition: inline
In-Reply-To: <1432914731.7456.91.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Fri, May 29, 2015 at 08:52:11AM -0700, Eric Dumazet wrote:
> On Fri, 2015-05-29 at 08:12 -0700, Stephen Hemminger wrote:
> > I think 2.6.32 is so old no one will care.

A few will still, but at least we must ensure the old guy finishes
his days nicely :-)

(...)
> I guess a backport went wrong.

Ah crap, sorry about that :-(

> Willy, please add following to your tree :
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 5339f066234b..d1e2895bb63c 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2136,7 +2136,7 @@ void tcp_send_fin(struct sock *sk)
>  	 */
>  	if (tskb && (tcp_send_head(sk) || tcp_memory_pressure)) {
>  coalesce:
> -		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_FIN;
> +		TCP_SKB_CB(tskb)->flags |= TCPCB_FLAG_FIN;
>  		TCP_SKB_CB(tskb)->end_seq++;
>  		tp->write_seq++;
>  	if (!tcp_send_head(sk)) {


Thanks Eric, I'm queuing this now.

Best regards,
Willy
