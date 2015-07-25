From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v4 net-next 1/4] tcp: replace cnt & rtt with struct
 in pkts_acked()
Date: Sat, 25 Jul 2015 08:22:12 +0200
Message-ID: <1437805332.20182.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1437792426-1724090-1-git-send-email-brakmo@fb.com>
	 <1437792426-1724090-2-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:34331 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754799AbbGYGWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 02:22:17 -0400
Received: by wibud3 with SMTP id ud3so84208130wib.1
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 23:22:15 -0700 (PDT)
In-Reply-To: <1437792426-1724090-2-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-24 at 19:47 -0700, Lawrence Brakmo wrote:
> Replace 2 arguments (cnt and rtt) in the congestion control modules'
> pkts_acked() function with a struct. This will allow adding more
> information without having to modify existing congestion control
> modules (tcp_nv in particular needs bytes in flight when packet
> was sent).
> 
>  
> +struct ack_sample {
> +	u32 pkts_acked;
> +	s32 rtt_us;
> +};
> +
>  struct tcp_congestion_ops {
>  	struct list_head	list;
>  	u32 key;
> @@ -857,7 +862,7 @@ struct tcp_congestion_ops {
>  	/* new value of cwnd after loss (optional) */
>  	u32  (*undo_cwnd)(struct sock *sk);
>  	/* hook for packet ack accounting (optional) */
> -	void (*pkts_acked)(struct sock *sk, u32 num_acked, s32 rtt_us);
> +	void (*pkts_acked)(struct sock *sk, struct ack_sample *sample);

This probably should be a const struct ack_sample *sample ?
