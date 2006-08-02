From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/23] [PATCH] [XFRM]: Trace which secpath state is
 reject factor.
Date: Tue, 01 Aug 2006 17:15:01 -0700 (PDT)
Message-ID: <20060801.171501.95894508.davem@davemloft.net>
References: <11541654291610-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53646
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750836AbWHBAPB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 20:15:01 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <11541654291610-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Sat, 29 Jul 2006 18:30:29 +0900

> @@ -272,6 +272,9 @@ #define XFRM_TYPE_NON_FRAGMENT	1
>  	void			(*destructor)(struct xfrm_state *);
>  	int			(*input)(struct xfrm_state *, struct sk_buff *skb);
>  	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
> +#ifdef CONFIG_XFRM_ADVANCED
> +	int			(*reject)(struct xfrm_state *, struct sk_buff *skb, struct flowi *);
> +#endif

xfrm_secpath_reject() unconditionally dereferences this new reject
operation pointer, but this patch contains no assignments of it.

Please send incremental patches that are fully functional all by
themselves, so that if each one is applied, it would compile and
work.
