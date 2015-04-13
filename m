From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp/dccp: get rid of central timewait timer
Date: Mon, 13 Apr 2015 08:23:58 -0700
Message-ID: <1428938638.3834.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1428693574.25985.326.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1428889869.25985.375.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:37621 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652AbbDMPYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 11:24:01 -0400
Received: by igblo3 with SMTP id lo3so46956538igb.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 08:24:00 -0700 (PDT)
In-Reply-To: <1428889869.25985.375.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-04-12 at 18:51 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>

> -void inet_twsk_schedule(struct inet_timewait_sock *tw,
> -		       struct inet_timewait_death_row *twdr,
> -		       const int timeo, const int timewait_len)
> +void inet_twsk_schedule(struct inet_timewait_sock *tw, const int timeo)
>  {
> -	struct hlist_head *list;
> -	int slot;
> -
>  	/* timeout := RTO * 3.5
>  	 *
>  	 * 3.5 = 1+2+0.5 to wait for two retransmits.
> @@ -367,115 +269,15 @@ void inet_twsk_schedule(struct inet_timewait_sock *tw,
>  	 * is greater than TS tick!) and detect old duplicates with help
>  	 * of PAWS.
>  	 */
> -	slot = (timeo + (1 << INET_TWDR_RECYCLE_TICK) - 1) >> INET_TWDR_RECYCLE_TICK;
>  
> -	spin_lock(&twdr->death_lock);
> -
> -	/* Unlink it, if it was scheduled */
> -	if (inet_twsk_del_dead_node(tw))
> -		twdr->tw_count--;
> -	else
> +	tw->tw_kill = timeo <= 4*HZ;	

I noticed extra spaces at the end of this line, I can either resend a v3
or let you remove this, thanks !
