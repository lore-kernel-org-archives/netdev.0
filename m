From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v2] act_nat: fix the wrong checksum when addr isn't in
 old_addr/mask
Date: Sun, 30 May 2010 08:43:41 -0400
Message-ID: <1275223421.3587.0.camel@bigi>
References: <1275179219-10424-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:36338 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540Ab0E3Mnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 08:43:47 -0400
Received: by vws11 with SMTP id 11so1009868vws.19
        for <netdev@vger.kernel.org>; Sun, 30 May 2010 05:43:46 -0700 (PDT)
In-Reply-To: <1275179219-10424-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Copying Herbert, taking linux-kernel off...

On Sun, 2010-05-30 at 08:26 +0800, Changli Gao wrote:
> fix the wrong checksum when addr isn't in old_addr/mask
> 
> For TCP and UDP packets, when addr isn't in old_addr/mask we don't do SNAT or
> DNAT, and we should not update layer 4 checksum.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  net/sched/act_nat.c |    4 ++++
>  1 file changed, 4 insertions(+)
> diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
> index d885ba3..5709494 100644
> --- a/net/sched/act_nat.c
> +++ b/net/sched/act_nat.c
> @@ -159,6 +159,9 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
>  			iph->daddr = new_addr;
>  
>  		csum_replace4(&iph->check, addr, new_addr);
> +	} else if ((iph->frag_off & htons(IP_OFFSET)) ||
> +		   iph->protocol != IPPROTO_ICMP) {
> +		goto out;
>  	}
>  
>  	ihl = iph->ihl * 4;
> @@ -247,6 +250,7 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
>  		break;
>  	}
>  
> +out:
>  	return action;
>  
>  drop:

