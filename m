From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] ipv6: fix incorrent ipv6 ipsec packet fragment
Date: Mon, 19 Mar 2012 09:02:20 +0100
Message-ID: <20120319080220.GA29891@secunet.com>
References: <1331888235-10368-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:59738 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753013Ab2CSICY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 04:02:24 -0400
Content-Disposition: inline
In-Reply-To: <1331888235-10368-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 16, 2012 at 04:57:15PM +0800, Gao feng wrote:
> Since commit 299b0767(ipv6: Fix IPsec slowpath fragmentation problem)
> In func ip6_append_data,after call skb_put(skb, fraglen + dst_exthdrlen)
> the skb->len contains dst_exthdrlen,and we don't reduce dst_exthdrlen at last
> This will make fraggap>0 in next "while cycle",and cause the size of skb incorrent

Good catch!

> 
> Call skb_pull reduce skb->len before next "while cycle"

I think it would be better to just reserve headroom for
dst_exthdrlen instead of adding and removing data to/from
the skb.
