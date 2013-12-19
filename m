From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 1/2] netfilter_queue: enable UID/GID socket info
 retrieval
Date: Thu, 19 Dec 2013 12:43:40 +0100
Message-ID: <20131219114340.GB6047@breakpoint.cc>
References: <1387451007-14363-1-git-send-email-valentina.giusti@bmw-carit.de>
 <1387451007-14363-2-git-send-email-valentina.giusti@bmw-carit.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	fw@strlen.de, eric.dumazet@gmail.com, tgraf@redhat.com,
	jpa@google.com, pablo@netfilter.org, davem@davemloft.net,
	daniel.wagner@bmw-carit.de,
	Valentina Giusti <valentina.giusti@oss.bmw-carit.de>
To: valentina.giusti@bmw-carit.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1387451007-14363-2-git-send-email-valentina.giusti@bmw-carit.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

valentina.giusti@bmw-carit.de <valentina.giusti@bmw-carit.de> wrote:
> From: Valentina Giusti <valentina.giusti@oss.bmw-carit.de>
> 
> Thanks to commits 41063e9 (ipv4: Early TCP socket demux) and 421b388 (udp: ipv4:
> Add udp early demux) it is now possible to parse UID and GID socket info
> also for incoming TCP and UDP connections. Having this info available, it
> is convenient to let NFQUEUE parse it in order to improve and refine the
> traffic analysis in userspace.

> diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
> index 21258cf..2cdef07 100644
> --- a/net/netfilter/nfnetlink_queue_core.c
> +++ b/net/netfilter/nfnetlink_queue_core.c
> @@ -297,6 +297,29 @@ nfqnl_put_packet_info(struct sk_buff *nlskb, struct sk_buff *packet,
>  	return flags ? nla_put_be32(nlskb, NFQA_SKB_INFO, htonl(flags)) : 0;
>  }
>  
> +static int nfqnl_put_sk_uidgid(struct sk_buff *skb, struct sock *sk)
> +{
> +	const struct cred *cred;
> +
> +	if (sk && sk->sk_state != TCP_TIME_WAIT) {
[..]
> +	if ((queue->flags & NFQA_CFG_F_UID_GID) && entskb->sk)
> +		if (nfqnl_put_sk_uidgid(skb, entskb->sk))
> +			goto nla_put_failure;

Minor nit: sk is tested for non-null twice.  Suggestion:

if ((queue->flags & NFQA_CFG_F_UID_GID) &&
     nfqnl_put_sk_uidgid(skb, entskb->sk))
          goto nla_put_failure;

I don't think its necessary to resubmit the patch though, thus:

Reviewed-by: Florian Westphal <fw@strlen.de>
