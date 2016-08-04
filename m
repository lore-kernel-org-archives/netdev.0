From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use non-compound pages in frag allocator
Date: Thu, 04 Aug 2016 15:50:47 +0200
Message-ID: <1470318647.13693.28.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1470314858-32105-1-git-send-email-ilyal@mellanox.com>
	 <1470317089.13693.23.camel@edumazet-glaptop3.roam.corp.google.com>
	 <VI1PR0501MB1968D785003AA94C1EB0F226D4070@VI1PR0501MB1968.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"edumazet@google.com" <edumazet@google.com>
To: Ilya Lesokhin <ilyal@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34581 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933411AbcHDNvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 09:51:31 -0400
Received: by mail-wm0-f66.google.com with SMTP id q128so44672816wma.1
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 06:50:51 -0700 (PDT)
In-Reply-To: <VI1PR0501MB1968D785003AA94C1EB0F226D4070@VI1PR0501MB1968.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-04 at 13:38 +0000, Ilya Lesokhin wrote:
> You are right I just realized that this patch causes a memory leak, so sorry for the spam.
> 
> I just had problem understanding when compound pages are needed and when It is enough to use an high order pages.
> I thought that that high order pages are enough for this use case, tested it and saw no problems.
> 
> Unfortunately it seems you must use compound pages to keep track of  the page order.
> put_page assumes that the order of a non-compound page is always 0. 
> It would be nice to document it somewhere but I'm not sure where.

Please do not top-post on netdev mailing list.

( Documentation/development-process/2.Process : line 422 )

AFAIK, only when we can call free_pages(p, order) and provide @order, we
can avoid using __GFP_COMP at alloc time.

But if some path has to use put_page(), then we are forced to use
__GFP_COMP for high order pages.

Thanks.
