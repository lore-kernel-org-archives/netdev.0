From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] udp: don't rereference dst_entry dev pointer on rcv
Date: Thu, 07 Mar 2013 14:47:24 -0800
Message-ID: <1362696444.15793.220.camel@edumazet-glaptop>
References: <1362695800-8633-1-git-send-email-tparkin@katalix.com>
	 <1362695800-8633-2-git-send-email-tparkin@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:51671 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993Ab3CGWr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 17:47:27 -0500
Received: by mail-pa0-f47.google.com with SMTP id bj3so803880pad.20
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 14:47:27 -0800 (PST)
In-Reply-To: <1362695800-8633-2-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-07 at 22:36 +0000, Tom Parkin wrote:
> When a fragmented IP packet is queued during device teardown, it is possible
> for the reassembled packet to hit the UDP rcv path with a NULL dst_entry dev
> pointer.  Drop such packets to prevent an oops.
> ---
>  net/ipv4/udp.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 0a073a2..c38a4b1 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1700,6 +1700,9 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
>  		return __udp4_lib_mcast_deliver(net, skb, uh,
>  				saddr, daddr, udptable);
>  
> +	if (skb_dst(skb)->dev == NULL)
> +		goto drop;
> +
>  	sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
>  
>  	if (sk != NULL) {


Hmm... couldnt it be tested in reassembly layer instead ?

Why is it specific to UDP ?
