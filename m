From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 v3] xps: Improvements in TX queue selection
Date: Sun, 24 Oct 2010 15:32:06 -0700 (PDT)
Message-ID: <20101024.153206.179940220.davem@davemloft.net>
References: <alpine.DEB.1.00.1010211303390.30535@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38231
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755709Ab0JXWbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 18:31:43 -0400
In-Reply-To: <alpine.DEB.1.00.1010211303390.30535@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 21 Oct 2010 13:17:08 -0700 (PDT)

> @@ -822,8 +822,10 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
>  							   &md5);
>  	tcp_header_size = tcp_options_size + sizeof(struct tcphdr);
>  
> -	if (tcp_packets_in_flight(tp) == 0)
> +	if (tcp_packets_in_flight(tp) == 0) {
>  		tcp_ca_event(sk, CA_EVENT_TX_START);
> +		skb->ooo_okay = 1;
> +	}
>  

You'll need to clear this flag the moment the first transmit of
this packet happens, otherwise OOO won't be handled correctly in
the event that fast retransmit is necessary later.
