From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] netpoll: fix netpoll_send_udp() bugs
Date: Wed, 13 Jun 2012 13:59:35 +0000 (UTC)
Message-ID: <jra6c7$tj4$1@dough.gmane.org>
References: <1339565421.22704.310.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:48960 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753732Ab2FMN7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 09:59:55 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Seo6w-0002d0-GS
	for netdev@vger.kernel.org; Wed, 13 Jun 2012 15:59:50 +0200
Received: from 117.69.252.18 ([117.69.252.18])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2012 15:59:50 +0200
Received: from xiyou.wangcong by 117.69.252.18 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2012 15:59:50 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Jun 2012 at 05:30 GMT, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Bogdan Hamciuc diagnosed and fixed following bug in netpoll_send_udp() :
>
> "skb->len += len;" instead of "skb_put(skb, len);"
>
> Meaning that _if_ a network driver needs to call skb_realloc_headroom(),
> only packet headers would be copied, leaving garbage in the payload.
>
> However the skb_realloc_headroom() must be avoided as much as possible
> since it requires memory and netpoll tries hard to work even if memory
> is exhausted (using a pool of preallocated skbs)
>
> It appears netpoll_send_udp() reserved 16 bytes for the ethernet header,
> which happens to work for typicall drivers but not all.
>
> Right thing is to use LL_RESERVED_SPACE(dev)
> (And also add dev->needed_tailroom of tailroom)
>
> This patch combines both fixes.
>
> Many thanks to Bogdan for raising this issue.
>

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>

Need to apply to -stable?

Thanks.
