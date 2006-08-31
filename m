From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix sk->sk_filter field access
Date: Thu, 31 Aug 2006 15:29:53 -0700 (PDT)
Message-ID: <20060831.152953.70199567.davem@davemloft.net>
References: <200608301707.14250.dim@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, dev@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10671
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932216AbWHaW3r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 18:29:47 -0400
To: dim@openvz.org
In-Reply-To: <200608301707.14250.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Mishin <dim@openvz.org>
Date: Wed, 30 Aug 2006 17:07:14 +0400

> Function sk_filter() is called from tcp_v{4,6}_rcv() functions with argue 
> needlock = 0, while socket is not locked at that moment. In order to avoid 
> this and similar issues in the future, use rcu for sk->sk_filter field read 
> protection.
> 
> Patch is for net-2.6.19
> 
> Signed-off-by: Dmitry Mishin <dim@openvz.org>
> Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Signed-off-by: Kirill Korotaev <dev@openvz.org>

Dmitry, your email client chopped up the longer lines in the patch
such as:

> -static inline int sk_filter(struct sock *sk, struct sk_buff *skb, int 
> needlock)
> +static inline int sk_filter(struct sock *sk, struct sk_buff *skb)

Here.

> -static inline unsigned run_filter(struct sk_buff *skb, struct sock *sk, 
> unsigned res)
> +static inline int run_filter(struct sk_buff *skb, struct sock *sk,

And there.

But I fixed these up and applied the patch to net-2.6.19

I think we seriously need to think about fixing this bug,
in so me form, for 2.6.18
