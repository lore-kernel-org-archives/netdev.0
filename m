From: David Miller <davem@davemloft.net>
Subject: Re: [Resend PATCH 1/3] TCP: Fix MD5 signatures for non-linear skbs
Date: Wed, 16 Jul 2008 20:40:40 -0700 (PDT)
Message-ID: <20080716.204040.127241370.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe069011@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43922
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752654AbYGQDkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 23:40:40 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069011@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Tue, 15 Jul 2008 09:30:40 -0700

> @@ -1155,6 +1148,11 @@ extern void			tcp_free_md5sig_pool(void);
>  
>  extern struct tcp_md5sig_pool	*__tcp_get_md5sig_pool(int cpu);
>  extern void			__tcp_put_md5sig_pool(void);
> +extern int tcp_md5_hash_header(struct tcp_md5sig_pool *, struct tcphdr *);
> +extern int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *, struct sk_buff *,
> +				 unsigned header_len);
> +extern int tcp_md5_hash_key(struct tcp_md5sig_pool *hp,
> +			    struct tcp_md5sig_key *key);

You don't have any module exports for these functions,
yet they are called from tcp_ipv6.c, and that will cause
a build failure.
