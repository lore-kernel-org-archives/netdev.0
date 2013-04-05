From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: don't reset nf_trace in nf_reset()
Date: Fri, 05 Apr 2013 14:56:53 -0400 (EDT)
Message-ID: <20130405.145653.2046071452089341484.davem@davemloft.net>
References: <1365187325-25147-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, gaofeng@cn.fujitsu.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1365187325-25147-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri,  5 Apr 2013 20:42:05 +0200

> Commit 130549fe added code to reset nf_trace in nf_reset(). This is wrong
> and unnecessary.
> 
> nf_reset() is used in the following cases:
> 
> - when passing packets up the the socket layer, at which point we want to
>   release all netfilter references that might keep modules pinned while
>   the packet is queued. nf_trace doesn't matter anymore at this point.
> 
> - when encapsulating or decapsulating IPsec packets. We want to continue
>   tracing these packets after IPsec processing.
> 
> - when passing packets through virtual network devices. Only devices on
>   that encapsulate in IPv4/v6 matter since otherwise nf_trace is not
>   used anymore. Its not entirely clear whether those packets should
>   be traced after that, however we've always done that.
> 
> - when passing packets through virtual network devices that make the
>   packet cross network namespace boundaries. This is the only cases
>   where we clearly want to reset nf_trace and is also what the
>   original patch intended to fix.
> 
> Add a new function nf_reset_trace() and use it in dev_forward_skb() to
> fix this properly.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

I'll apply this directly because I'm trying to get a pull request out
to Linus.
