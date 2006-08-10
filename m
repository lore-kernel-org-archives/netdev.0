From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: skb_shared_info()
Date: Thu, 10 Aug 2006 23:49:14 +0400
Message-ID: <20060810194914.GA29976@2ka.mipt.ru>
References: <20060808.163915.03600382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:8851 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932299AbWHJTuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 15:50:09 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060808.163915.03600382.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 04:39:15PM -0700, David Miller (davem@davemloft.net) wrote:
> 
> I'm beginning to think that where we store the
> skb_shared_info() is a weakness of the SKB design.

Food for thoughts - unix sockets can use PAGE_SIZEd chunks of memory
(and they do it almost always), which are aligned to 2*PAGE_SIZE due to
alignment issues with skb_shared_info, so unix sockets waste 3.5 kb of
memory on each skb. I think it is time to resurrect idea of placing
shared_info inside skb and allow to allocate it from own cache for
special cases, what do you think?

-- 
	Evgeniy Polyakov
