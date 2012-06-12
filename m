From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netpoll: Fix skb tail pointer in netpoll_send_udp()
Date: Tue, 12 Jun 2012 15:34:09 +0200
Message-ID: <1339508049.22704.143.camel@edumazet-glaptop>
References: <1339496765-3093-1-git-send-email-bogdan.hamciuc@freescale.com>
	 <1339503766.22704.116.camel@edumazet-glaptop>
	 <1339506917.22704.134.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50133 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab2FLNeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 09:34:16 -0400
Received: by eeit10 with SMTP id t10so2217408eei.19
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 06:34:15 -0700 (PDT)
In-Reply-To: <1339506917.22704.134.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-12 at 15:15 +0200, Eric Dumazet wrote:
> On Tue, 2012-06-12 at 14:22 +0200, Eric Dumazet wrote:

> > Hmm, real question is why skb_realloc_headroom() is even necessary...
> > 
> > I suspect we need to reserve more bytes.
> > 
> > 	total_len = ip_len + ETH_HLEN + NET_IP_ALIGN + NET_SKB_PAD;
> > 
> > or something like that ?
> > 
> > Which driver triggers the bug ?
> > 

In case you wonder why I try so hard to avoid the
skb_realloc_headroom() :

netpoll has complicated^Wspecial^Wnice skb cache, to make sure it can
work even if memory is exhausted.

But if we trigger skb_realloc_headroom() the whole thing is useless. 

Thanks
