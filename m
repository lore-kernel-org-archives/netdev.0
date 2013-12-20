From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v3 1/2] netfilter_queue: enable UID/GID socket info
 retrieval
Date: Fri, 20 Dec 2013 15:09:59 +0100
Message-ID: <20131220140959.GA29632@breakpoint.cc>
References: <1387542820-16319-1-git-send-email-valentina.giusti@bmw-carit.de>
 <1387542820-16319-2-git-send-email-valentina.giusti@bmw-carit.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	fw@strlen.de, jpa@google.com, pablo@netfilter.org,
	daniel.wagner@bmw-carit.de
To: valentina.giusti@bmw-carit.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1387542820-16319-2-git-send-email-valentina.giusti@bmw-carit.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

valentina.giusti@bmw-carit.de <valentina.giusti@bmw-carit.de> wrote:
> --- a/net/netfilter/nfnetlink_queue_core.c
> +++ b/net/netfilter/nfnetlink_queue_core.c
> @@ -297,6 +297,32 @@ nfqnl_put_packet_info(struct sk_buff *nlskb, struct sk_buff *packet,
>  	return flags ? nla_put_be32(nlskb, NFQA_SKB_INFO, htonl(flags)) : 0;
>  }
>  
> +static int nfqnl_put_sk_uidgid(struct sk_buff *skb, struct sock *sk)
> +{
> +	const struct cred *cred;
> +
> +	if (sk->sk_state == TCP_TIME_WAIT)
> +		return -1;

I think this should be 'return 0'?
