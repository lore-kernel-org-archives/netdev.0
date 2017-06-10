From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: reflect mark on tcp syn ack packets
Date: Sat, 10 Jun 2017 19:02:13 -0400 (EDT)
Message-ID: <20170610.190213.1437094451353913622.davem@davemloft.net>
References: <1497101461-20921-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com, mrv@mojatatu.com,
        hadi@mojatatu.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37624 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751660AbdFJXCP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 19:02:15 -0400
In-Reply-To: <1497101461-20921-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sat, 10 Jun 2017 09:31:01 -0400

> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 7a3fd25..a8fd5f0 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -173,7 +173,8 @@ int ip_build_and_send_pkt(struct sk_buff *skb, const struct sock *sk,
>  	}
>  
>  	skb->priority = sk->sk_priority;
> -	skb->mark = sk->sk_mark;
> +	if (!skb->mark)
> +		skb->mark = sk->sk_mark;

Maybe this should both be "inet_request_mark()"?

Also, Lorenzo, please review.
