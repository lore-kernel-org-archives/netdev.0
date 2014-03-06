From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] l2tp: fix manual sequencing (de)activation in
 L2TPv2
Date: Wed, 05 Mar 2014 20:39:51 -0500 (EST)
Message-ID: <20140305.203951.1253631868817773239.davem@davemloft.net>
References: <cover.1393966618.git.g.nault@alphalink.fr>
	<7badd5856e70fd63f8b74b361fb499cc8ed7f065.1393966618.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756397AbaCFBjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 20:39:53 -0500
In-Reply-To: <7badd5856e70fd63f8b74b361fb499cc8ed7f065.1393966618.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Tue, 4 Mar 2014 22:25:23 +0100

> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index 735d0f6..735750f 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -112,7 +112,7 @@ struct l2tp_net {
>  	spinlock_t l2tp_session_hlist_lock;
>  };
>  
> -static void l2tp_session_set_header_len(struct l2tp_session *session, int version);
> +void l2tp_session_set_header_len(struct l2tp_session *session, int version);
>  static void l2tp_tunnel_free(struct l2tp_tunnel *tunnel);
>  
>  static inline struct l2tp_tunnel *l2tp_tunnel(struct sock *sk)

You can just remove the declaration...

> diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
> index 1f01ba3..3f93ccd 100644
> --- a/net/l2tp/l2tp_core.h
> +++ b/net/l2tp/l2tp_core.h
> @@ -263,6 +263,7 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
>  		      int length, int (*payload_hook)(struct sk_buff *skb));
>  int l2tp_session_queue_purge(struct l2tp_session *session);
>  int l2tp_udp_encap_recv(struct sock *sk, struct sk_buff *skb);
> +void l2tp_session_set_header_len(struct l2tp_session *session, int version);
>  
>  int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb,
>  		  int hdr_len);

Because you added it there.

Please fix this up and resubmit this series, thanks.
