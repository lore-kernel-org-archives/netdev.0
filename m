From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3 net-next 1/3] ipv4: rename ip_options_echo to
 __ip_options_echo()
Date: Thu, 25 Sep 2014 13:30:08 -0700
Message-ID: <1411677008.3460.7.camel@joe-AO725>
References: <1411676092-16196-1-git-send-email-edumazet@google.com>
	 <1411676092-16196-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Christoph Paasch <christoph.paasch@uclouvain.be>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0023.hostedemail.com ([216.40.44.23]:59652 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750889AbaIYUaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 16:30:12 -0400
In-Reply-To: <1411676092-16196-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-25 at 13:14 -0700, Eric Dumazet wrote:
> ip_options_echo() assumes struct ip_options is provided in &IPCB(skb)->opt
> Lets break this assumption, but provide a helper to not change all call points.
[]
> diff --git a/include/net/ip.h b/include/net/ip.h
[]
> @@ -511,7 +513,14 @@ int ip_forward(struct sk_buff *skb);
>   
>  void ip_options_build(struct sk_buff *skb, struct ip_options *opt,
>  		      __be32 daddr, struct rtable *rt, int is_frag);
> -int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb);
> +
> +int __ip_options_echo(struct ip_options *dopt, struct sk_buff *skb,
> +		      const struct ip_options *sopt);

Thanks Eric.

Unrelated:

I wonder how much effort, if any, should be made to convert
struct sk_buff * to const struct sk_buff * where appropriate.

For instance:

This __ip_options_echo could use const struct sk_buff *skb
if fib_compute_spec_dst was changed to const struct sk_buff *skb.
