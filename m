From: Florian Westphal <fw@strlen.de>
Subject: Re: [Patch net-next] net: rename local_df to ignore_df
Date: Mon, 5 May 2014 01:54:36 +0200
Message-ID: <20140504235436.GA32448@breakpoint.cc>
References: <1399246758-29795-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34998 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753905AbaEDXyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 19:54:38 -0400
Content-Disposition: inline
In-Reply-To: <1399246758-29795-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> wrote:
> As suggested by several people, rename local_df to ignore_df,
> since it means "ignore df bit if it is set".

Thanks for doing this.

David, this has small conflict with a patch I sent couple of hours ago.

Also, I do have another bug fix patch that will move a function
evaluating skb->local_df around [ ie. targeted at net tree ]

That patch needs more testing but I will send it within next 30 hours.

> diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
> index be8abe7..8ac422f 100644
> --- a/net/ipv4/ip_forward.c
> +++ b/net/ipv4/ip_forward.c
> @@ -42,12 +42,12 @@
>  static bool ip_may_fragment(const struct sk_buff *skb)
>  {
>  	return unlikely((ip_hdr(skb)->frag_off & htons(IP_DF)) == 0) ||
> -	       !skb->local_df;
> +	       !skb->ignore_df;

nicely illustrates why the rename is a good idea, IMO.

[ should read '|| skb->ignore_df', the negation is wrong ]
